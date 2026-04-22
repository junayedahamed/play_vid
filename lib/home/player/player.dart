import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'player_view_model/player_view_model.dart';
import 'widgets/player_top_bar.dart';
import 'widgets/player_progress_bar.dart';
import 'widgets/player_bottom_controls.dart';
import 'widgets/player_volume_overlay.dart';
import 'widgets/player_seek_overlay.dart';

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
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            children: [
              _buildVideoSurface(context, viewModel),
              if (viewModel.showOverlayProgressBar)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PlayerTopBar(
                    title: viewModel.currentTitle,
                    playbackSpeed: viewModel.playbackSpeed,
                    onBack: () => Navigator.pop(context),
                    onAudioSettings: () => _showAudioDialog(context, viewModel),
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
                        formatDuration: _formatDuration,
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

  Widget _buildVideoSurface(BuildContext context, PlayerViewModel viewModel) {
    // We use a gesture detector that covers the entire stack area
    return GestureDetector(
      // Toggle overlay on tap anywhere
      onTap: viewModel.handleTap,
      // Vertical drag for Volume in center/anywhere
      onVerticalDragStart: viewModel.onVerticalDragStart,
      onVerticalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        viewModel.onVerticalDragUpdate(details, box.size.height);
      },
      onVerticalDragEnd: viewModel.onVerticalDragEnd,
      // Horizontal drag for Seek in center/anywhere
      onHorizontalDragStart: viewModel.onHorizontalDragStart,
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        viewModel.onHorizontalDragUpdate(details, box.size.width);
      },
      onHorizontalDragEnd: viewModel.onHorizontalDragEnd,
      child: Container(
        // Making the container expand to fill the screen
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: AspectRatio(
            aspectRatio:
                viewModel.currentAspectRatio ??
                viewModel.controller.value.aspectRatio,
            child: VideoPlayer(viewModel.controller),
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  return "$twoDigitMinutes:$twoDigitSeconds";
}

void _showAudioDialog(BuildContext context, PlayerViewModel viewModel) {
  showCupertinoDialog(
    context: context,
    builder: (context) {
      bool tempValue = viewModel.isAudioDisabled;
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return CupertinoAlertDialog(
            title: const Text('Audio Settings'),
            content: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setDialogState(() => tempValue = !tempValue);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tempValue
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                    ),
                    const SizedBox(width: 8),
                    const Text('Disable Audio'),
                  ],
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  viewModel.setAudioDisabled(tempValue);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}
