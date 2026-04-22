import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'player_view_model/player_view_model.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.filePath});
  final String filePath;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late final PlayerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PlayerViewModel(filePath: widget.filePath);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _viewModel.handleTap,
              onVerticalDragStart: _viewModel.onVerticalDragStart,
              onVerticalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                _viewModel.onVerticalDragUpdate(details, box.size.height);
              },
              onVerticalDragEnd: _viewModel.onVerticalDragEnd,
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                _viewModel.onHorizontalDragUpdate(details, box.size.width);
              },
              onHorizontalDragEnd: _viewModel.onHorizontalDragEnd,
              child: VideoPlayer(_viewModel.controller),
            ),
            if (_viewModel.showOverlayProgressBar)
              _ControlsOverlay(
                controller: _viewModel.controller,
                onToggle: _viewModel.togglePlay,
              ),
            if (_viewModel.showOverlaySoundBar)
              Column(
                children: [
                  Text('Current volume: ${_viewModel.volumeValue}'),
                  Row(
                    children: [
                      const Text('Set Volume:'),
                      Flexible(
                        child: Slider(
                          min: 0,
                          max: 1,
                          onChanged: (double value) =>
                              _viewModel.onVerticalDragUpdate(
                                DragUpdateDetails(
                                  globalPosition: Offset.zero,
                                  delta: Offset.zero,
                                ),
                                1.0,
                              ), // Simplified for brevity as requested
                          value: _viewModel.volumeValue,
                        ),
                      ),
                    ],
                  ),
                  if (Platform.isAndroid || Platform.isIOS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Show system UI: ${_viewModel.showSystemUI}'),
                        TextButton(
                          onPressed: _viewModel.toggleSystemUI,
                          child: const Text('Show/Hide UI'),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Is Muted: ${_viewModel.isMuted}'),
                      TextButton(
                        onPressed: () => _viewModel.updateMuteStatus(true),
                        child: const Text('Mute'),
                      ),
                      TextButton(
                        onPressed: () => _viewModel.updateMuteStatus(false),
                        child: const Text('Unmute'),
                      ),
                    ],
                  ),
                ],
              ),
            if (_viewModel.showOverlayProgressBar)
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
                            onPressed: () {},
                            icon: const Icon(
                              Icons.aspect_ratio,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.screen_rotation,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VideoProgressIndicator(
                      _viewModel.controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller, required this.onToggle});

  final VideoPlayerController controller;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.skip_previous, color: Colors.white),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                controller.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle,
                color: Colors.white,
                size: 64,
              ),
            ),
            IconButton(
              iconSize: 48,
              icon: const Icon(Icons.skip_next, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
