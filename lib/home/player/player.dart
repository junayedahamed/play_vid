import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'player_view_model/player_view_model.dart';

class Player extends StatelessWidget {
  const Player({super.key, required this.filePath});
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlayerViewModel(filePath: filePath),
      builder: (context, _) {
        final viewModel = context.watch<PlayerViewModel>();

        if (!viewModel.controller.value.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
                  GestureDetector(
                    onTap: viewModel.handleTap,
                    onVerticalDragStart: viewModel.onVerticalDragStart,
                    onVerticalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      viewModel.onVerticalDragUpdate(details, box.size.height);
                    },
                    onVerticalDragEnd: viewModel.onVerticalDragEnd,
                    onHorizontalDragStart: viewModel.onHorizontalDragStart,
                    onHorizontalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      viewModel.onHorizontalDragUpdate(details, box.size.width);
                    },
                    onHorizontalDragEnd: viewModel.onHorizontalDragEnd,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio:
                            viewModel.currentAspectRatio ??
                            viewModel.controller.value.aspectRatio,
                        child: VideoPlayer(viewModel.controller),
                      ),
                    ),
                  ),
                  if (viewModel.showOverlaySoundBar)
                    Column(
                      children: [
                        Text('Current volume: ${viewModel.volumeValue}'),
                        Row(
                          children: [
                            const Text('Set Volume:'),
                            Flexible(
                              child: Slider(
                                min: 0,
                                max: 1,
                                onChanged: (double value) =>
                                    viewModel.setVolume(value),
                                value: viewModel.volumeValue,
                              ),
                            ),
                          ],
                        ),
                        if (Platform.isAndroid || Platform.isIOS)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Show system UI: ${viewModel.showSystemUI}'),
                              TextButton(
                                onPressed: viewModel.toggleSystemUI,
                                child: const Text('Show/Hide UI'),
                              ),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Is Muted: ${viewModel.isMuted}'),
                            TextButton(
                              onPressed: () => viewModel.updateMuteStatus(true),
                              child: const Text('Mute'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  viewModel.updateMuteStatus(false),
                              child: const Text('Unmute'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (viewModel.showOverlayProgressBar)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: viewModel.toggleAspectRatio,
                                  icon: Icon(
                                    viewModel.currentAspectRatio == null
                                        ? CupertinoIcons.fullscreen
                                        : viewModel.currentAspectRatio == 16 / 9
                                        ? CupertinoIcons.rectangle_on_rectangle
                                        : viewModel.currentAspectRatio == 4 / 3
                                        ? CupertinoIcons.rectangle
                                        : CupertinoIcons.square,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      viewModel.toggleRotation(context),
                                  icon: const Icon(
                                    CupertinoIcons.rotate_right,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 14,
                                    ),
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.red,
                                  ),
                                  child: Slider(
                                    value: viewModel
                                        .controller
                                        .value
                                        .position
                                        .inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          viewModel
                                              .controller
                                              .value
                                              .duration
                                              .inMilliseconds
                                              .toDouble(),
                                        ),
                                    max: viewModel
                                        .controller
                                        .value
                                        .duration
                                        .inMilliseconds
                                        .toDouble(),
                                    onChanged: (value) {
                                      final duration = viewModel
                                          .controller
                                          .value
                                          .duration
                                          .inMilliseconds;
                                      if (duration > 0) {
                                        viewModel.onSliderSeek(
                                          value / duration,
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(
                                        viewModel.controller.value.position,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(
                                        viewModel.controller.value.duration,
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(
                                  Icons.skip_previous,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                iconSize: 64,
                                icon: Icon(
                                  viewModel.controller.value.isPlaying
                                      ? Icons.pause_circle
                                      : Icons.play_circle,
                                  color: Colors.white,
                                ),
                                onPressed: viewModel.togglePlay,
                              ),
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(
                                  Icons.skip_next,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
