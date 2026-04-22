import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _controller;
  late final VolumeController _volumeController;
  // late final StreamSubscription<double> _subscription;
  bool showOverlayProgressBar = false;
  bool showOverlaySoundBar = false;

  double _currentVolume = 0;
  double _volumeValue = 0;
  bool _isMuted = false;
  double _dragStartVolume = 0;
  double _dragStartY = 0;
  Timer? _hideOverlayTimer;

  @override
  void initState() {
    _controller = VideoPlayerController.asset('assets/v.mp4')
      ..initialize().then((_) {
        setState(() {
          // play();
        });
      });
    _volumeController = VolumeController.instance;

    // Listen to system volume change
    // _subscription = _volumeController.addListener((volume) {
    //   setState(() => _volumeValue = volume);
    // }, fetchInitialVolume: true);

    _volumeController.isMuted().then(
      (isMuted) => setState(() => _isMuted = isMuted),
    );
    super.initState();
  }

  void play() {
    _controller.play();
  }

  void pause() {
    _controller.pause();
  }

  void stop() {
    _controller.pause();
    _controller.seekTo(const Duration(seconds: 0));
  }

  void replay() {
    _controller.seekTo(const Duration(seconds: 0));
    _controller.play();
  }

  Future<void> updateMuteStatus(bool isMute) async {
    await _volumeController.setMute(isMute);
    if (Platform.isIOS) {
      // On iOS, the system does not update the mute status immediately
      // You need to wait for the system to update the mute status
      await Future.delayed(Duration(milliseconds: 50));
    }
    _isMuted = await _volumeController.isMuted();

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _hideOverlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (_controller.value.isPlaying) {
                  // _controller.pause();
                  showOverlayProgressBar = true;
                  _hideOverlayTimer = Timer(
                    const Duration(seconds: 1, milliseconds: 200),
                    () {
                      showOverlayProgressBar = false;
                      setState(() {});
                    },
                  );
                } else {
                  // _controller.play();
                  showOverlayProgressBar = true;
                  _hideOverlayTimer = Timer(
                    const Duration(seconds: 1, milliseconds: 200),
                    () {
                      showOverlayProgressBar = false;
                      setState(() {});
                    },
                  );
                }
                setState(() {});
              },

              onVerticalDragStart: (details) async {
                showOverlaySoundBar = true;
                _dragStartY = details.globalPosition.dy;
                _dragStartVolume = await _volumeController.getVolume();
                setState(() {
                  _volumeValue = _dragStartVolume;
                });
              },
              onVerticalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final deltaY = _dragStartY - details.globalPosition.dy;
                final volumeDelta = deltaY / box.size.height;
                final newVolume = (_dragStartVolume + volumeDelta).clamp(
                  0.0,
                  1.0,
                );
                _volumeController.setVolume(newVolume);
                setState(() => _volumeValue = newVolume);
              },
              onVerticalDragEnd: (details) {
                showOverlaySoundBar = false;
                setState(() {});
              },

              onHorizontalDragUpdate: (details) {
                showOverlayProgressBar = true;
                setState(() {});
                final box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final relative = localPosition.dx / box.size.width;
                final position =
                    _controller.value.duration * relative.clamp(0, 1);
                _controller.seekTo(position);
              },
              onHorizontalDragEnd: (p) {
                _hideOverlayTimer = Timer(const Duration(seconds: 1), () {
                  showOverlayProgressBar = false;
                  setState(() {});
                });
              },

              child: VideoPlayer(_controller),
            ),

            // Slider(value: _controller., onChanged: onChanged)
            _ControlsOverlay(controller: _controller),
            // : SizedBox.shrink(),

            ///
            ///
            ///
            ///
            showOverlaySoundBar
                ? Column(
                    children: [
                      Text('Current volume: $_volumeValue'),
                      Row(
                        children: [
                          Text('Set Volume:'),
                          Flexible(
                            child: Slider(
                              min: 0,
                              max: 1,
                              onChanged: (double value) async =>
                                  await _volumeController.setVolume(value),
                              value: _volumeValue,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Volume is: $_currentVolume'),
                          TextButton(
                            onPressed: () async {
                              _currentVolume = await _volumeController
                                  .getVolume();
                              setState(() {});
                            },
                            child: Text('Get Volume'),
                          ),
                        ],
                      ),
                      if (Platform.isAndroid || Platform.isIOS)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Show system UI:${_volumeController.showSystemUI}',
                            ),
                            TextButton(
                              onPressed: () => setState(
                                () => _volumeController.showSystemUI =
                                    !_volumeController.showSystemUI,
                              ),
                              child: Text('Show/Hide UI'),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Is Muted:$_isMuted'),
                          TextButton(
                            onPressed: () async {
                              await updateMuteStatus(true);
                            },
                            child: Text('Mute'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await updateMuteStatus(false);
                            },
                            child: Text('Unmute'),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          _isMuted = await _volumeController.isMuted();
                          setState(() {});
                        },
                        child: Text('Update Mute Status'),
                      ),
                    ],
                  )
                : SizedBox.shrink(),

            ///
            ///
            showOverlayProgressBar
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white54,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ControlsOverlay> createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.controller.value.isPlaying
            ? widget.controller.pause()
            : widget.controller.play();
        setState(() {});
      },
      child: Center(
        child: Icon(
          widget.controller.value.isPlaying
              ? Icons.pause_circle
              : Icons.play_circle,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}
