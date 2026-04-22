import 'package:flutter/cupertino.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import 'package:play_vid/providers/video_provider.dart';
import '../widgets/video_controls.dart';
import '../widgets/brightness_volume_overlay.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late BetterPlayerController _playerController;
  late VideoProvider _videoProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videoProvider = context.read<VideoProvider>();
    _initializePlayer();
  }

  void _initializePlayer() {
    final video = _videoProvider.currentVideo;
    if (video == null) {
      return;
    }

    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      video.path,
      videoExtension: video.path.split('.').last,
    );

    _playerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControlsOnInitialize: true,
          enableProgressBar: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    _playerController.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
        _videoProvider.nextVideo();
        _reloadPlayer();
      }
    });
  }

  void _reloadPlayer() {
    _playerController.dispose();
    setState(() {
      _initializePlayer();
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Consumer<VideoProvider>(
          builder: (context, provider, _) {
            return Text(
              provider.currentVideo?.displayTitle ?? 'Video Player',
              style: const TextStyle(fontSize: 14),
            );
          },
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Better Player
            BetterPlayer(controller: _playerController),

            // Controls overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoControls(
                playerController: _playerController,
                onNextPressed: () {
                  _videoProvider.nextVideo();
                  _reloadPlayer();
                },
                onPreviousPressed: () {
                  _videoProvider.previousVideo();
                  _reloadPlayer();
                },
              ),
            ),

            // Brightness/Volume gesture overlay
            BrightnessVolumeOverlay(playerController: _playerController),
          ],
        ),
      ),
    );
  }
}
