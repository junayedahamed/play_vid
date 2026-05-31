import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:play_vid/home/ip/view/widgets/ip_video_dialogue.dart';
import 'package:play_vid/home/ip/view/widgets/ip_video_surface.dart';
import 'package:play_vid/home/ip/view_model/view_model.dart';
import 'package:play_vid/home/player/widgets/player_brightness_overlay.dart';
import 'package:play_vid/home/player/widgets/player_top_bar.dart';
import 'package:play_vid/home/player/widgets/player_volume_overlay.dart';
import 'package:provider/provider.dart';

import 'package:play_vid/home/player/widgets/player_seek_overlay.dart';
import 'package:play_vid/home/player/widgets/player_progress_bar.dart';
import 'package:play_vid/home/player/widgets/player_utils.dart';

class IpPlayer extends StatelessWidget {
  const IpPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<IPplayerViewModel>();

    // Show persistent snackbar on error
    // if (viewModel.hasError) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           viewModel.errorMessage ??
    //               'An error occurred while loading stream',
    //         ),
    //         duration: const Duration(seconds: 5),
    //         action: SnackBarAction(
    //           label: 'RETRY',
    //           onPressed: () => viewModel.updateAssets(
    //             viewModel.channels,
    //             viewModel.currentIndex,
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }

    if (!viewModel.isInitialized && !viewModel.hasError) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );
    }

    if (viewModel.hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Failed to load stream',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Something went wrong while loading the stream or Stream is temporarily unavailable.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              // ElevatedButton.icon(
              //   onPressed: () => viewModel.updateAssets(
              //     viewModel.channels,
              //     viewModel.currentIndex,
              //   ),
              //   icon: const Icon(Icons.refresh),
              //   label: const Text('RETRY'),
              // ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        viewModel.resetRotation();
        if (!viewModel.isBackgroundPlay) {
          viewModel.stop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: [
              IpVideoSurface(viewModel: viewModel),
              if (viewModel.controller.value.isBuffering)
                const Center(
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                    radius: 20,
                  ),
                ),
              if (viewModel.showOverlayProgressBar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PlayerTopBar(
                    title: viewModel.currentTitle,
                    playbackSpeed: viewModel.playbackSpeed,
                    onBack: () => Navigator.pop(context),
                    onAudioSettings: () =>
                        showAudioDialogIp(context, viewModel),
                    onBackgroundPlay: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Background play is not supported for IP TV',
                          ),
                        ),
                      );
                    },
                    // viewModel.toggleBackgroundPlay(context),
                    onPlaybackSpeedChanged: (speed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Playback speed adjustment is not supported for IP TV',
                          ),
                        ),
                      );
                    },
                    // viewModel.setPlaybackSpeed(speed),
                  ),
                ),
              if (viewModel.showOverlaySoundBar)
                Align(
                  alignment: Alignment.center,
                  child: PlayerVolumeOverlay(
                    volume: viewModel.volumeValue,
                    showSystemUI: viewModel.showSystemUI,
                    isMuted: viewModel.isMuted,
                    onVolumeChanged: viewModel.setVolume,
                    onToggleSystemUI: viewModel.toggleSystemUI,
                    onToggleMute: (mute) => viewModel.updateMuteStatus(mute),
                  ),
                ),
              if (viewModel.showOverlayBrightness)
                Align(
                  alignment: Alignment.center,
                  child: PlayerBrightnessOverlay(
                    brightness: viewModel.brightnessValue,
                  ),
                ),
              if (viewModel.showOverlaySeek)
                Align(
                  alignment: Alignment.center,
                  child: PlayerSeekOverlay(seekOffset: viewModel.seekValue),
                ),
              if (viewModel.showOverlayProgressBar)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Using the seek bar for long network videos,
                      // but simplified controls below
                      PlayerProgressBar(
                        position: viewModel.controller.value.position,
                        duration: viewModel.controller.value.duration,
                        onSeek: (val) => viewModel.onSliderSeek(val),
                        formatDuration: formatDuration,
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 24, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: viewModel.toggleAspectRatio,
                              child: const Icon(
                                CupertinoIcons.fullscreen,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: viewModel.togglePlay,
                              child: Icon(
                                viewModel.controller.value.isPlaying
                                    ? CupertinoIcons.pause_circle_fill
                                    : CupertinoIcons.play_circle_fill,
                                color: Colors.white,
                                size: 72,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  viewModel.toggleRotation(context),
                              child: const Icon(
                                CupertinoIcons.rotate_right,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
