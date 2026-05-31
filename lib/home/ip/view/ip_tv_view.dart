import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class IpTvView extends StatefulWidget {
  const IpTvView({super.key, required this.url});
  final String url;
  @override
  State<IpTvView> createState() => _IpTvViewState();
}

class _IpTvViewState extends State<IpTvView> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      // Set a 15-second timeout for initialization
      await _controller.initialize().timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() {});
      _controller.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        if (e is TimeoutException) {
          _errorMessage = 'Loading timed out. The stream may be offline.';
        } else {
          _errorMessage = 'Failed to load video. Please check your connection.';
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IP TV')),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _errorMessage ?? 'Unknown error occurred',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorMessage = null;
                      });
                      _initializePlayer();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              )
            : _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading stream...'),
                ],
              ),
      ),
      floatingActionButton: _controller.value.isInitialized && !_hasError
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
