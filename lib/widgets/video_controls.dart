import 'package:flutter/cupertino.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:provider/provider.dart';
import 'package:play_vid/providers/device_controls_provider.dart';
import 'package:play_vid/services/subtitle_service.dart';
import '../models/video.dart';
import '../providers/video_provider.dart';

class VideoControls extends StatefulWidget {
  final BetterPlayerController playerController;
  final VoidCallback onNextPressed;
  final VoidCallback onPreviousPressed;

  const VideoControls({
    Key? key,
    required this.playerController,
    required this.onNextPressed,
    required this.onPreviousPressed,
  }) : super(key: key);

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _showControls = true;
  BoxFit _currentFit = BoxFit.contain;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.black.withOpacity(0),
                CupertinoColors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Control buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Previous button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onPreviousPressed,
                      child: const Icon(
                        CupertinoIcons.back,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                    // Subtitle button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _showSubtitlePicker,
                      child: const Icon(
                        CupertinoIcons.textformat,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                    // Fit/Resize button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleFit,
                      child: const Icon(
                        CupertinoIcons.arrowtriangle_down_fill,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                    // Fullscreen button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleFullscreen,
                      child: const Icon(
                        CupertinoIcons.fullscreen,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                    // Next button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: widget.onNextPressed,
                      child: const Icon(
                        CupertinoIcons.forward,
                        color: CupertinoColors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Mute button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<DeviceControlsProvider>(
                      builder: (context, controlsProvider, _) {
                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: CupertinoColors.systemBlue,
                          onPressed: () {
                            controlsProvider.toggleMute();
                            if (controlsProvider.isMuted) {
                              widget.playerController.setVolume(0);
                            } else {
                              widget.playerController.setVolume(
                                controlsProvider.volume,
                              );
                            }
                          },
                          child: Icon(
                            controlsProvider.isMuted
                                ? CupertinoIcons.speaker_slash_fill
                                : CupertinoIcons.speaker_2_fill,
                            color: CupertinoColors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFullscreen() {
    widget.playerController.enterFullScreen();
  }

  void _toggleFit() {
    setState(() {
      _currentFit = _currentFit == BoxFit.contain
          ? BoxFit.cover
          : BoxFit.contain;
    });
  }

  void _showSubtitlePicker() {
    final video = context.read<VideoProvider>().currentVideo;
    if (video == null) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: SubtitleService.getAvailableSubtitles(video.path),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoActivityIndicator();
            }

            final subtitles = snapshot.data ?? [];

            return CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: Column(
                children: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    isDefaultAction: subtitles.isEmpty,
                    child: const Text('No Subtitles'),
                  ),
                  ...subtitles.map((subtitle) {
                    return CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(SubtitleService.getSubtitleName(subtitle)),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
