import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player_view_model/player_view_model.dart';
import 'widgets/player_top_bar.dart';
import 'widgets/player_progress_bar.dart';
import 'widgets/player_bottom_controls.dart';
import 'widgets/player_volume_overlay.dart';
import 'widgets/player_seek_overlay.dart';
import 'widgets/video_surface.dart';
import 'widgets/audio_settings_dialog.dart';
import 'widgets/player_utils.dart';
import 'widgets/player_brightness_overlay.dart';

class Player extends StatelessWidget {
  const Player({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlayerViewModel>();

    if (!viewModel.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CupertinoActivityIndicator(color: Colors.white)),
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
              VideoSurface(viewModel: viewModel),
              if (viewModel.showOverlayProgressBar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PlayerTopBar(
                    title: viewModel.currentTitle,
                    playbackSpeed: viewModel.playbackSpeed,
                    onBack: () => Navigator.pop(context),
                    onAudioSettings: () => showAudioDialog(context, viewModel),
                    onBackgroundPlay: () =>
                        viewModel.toggleBackgroundPlay(context),
                    onPlaybackSpeedChanged: (speed) =>
                        viewModel.setPlaybackSpeed(speed),
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
                      PlayerProgressBar(
                        position: viewModel.controller.value.position,
                        duration: viewModel.controller.value.duration,
                        onSeek: (val) => viewModel.onSliderSeek(val),
                        formatDuration: formatDuration,
                      ),
                      PlayerBottomControls(
                        isPlaying: viewModel.controller.value.isPlaying,
                        repeatMode: viewModel.repeatMode,
                        onTogglePlay: viewModel.togglePlay,
                        onNext: viewModel.playNext,
                        onPrevious: viewModel.playPrevious,
                        onToggleRepeat: viewModel.cycleRepeatMode,
                        onToggleAspectRatio: viewModel.toggleAspectRatio,
                        onToggleRotation: () =>
                            viewModel.toggleRotation(context),
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
