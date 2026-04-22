import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../player_view_model/player_view_model.dart';

class PlayerBottomControls extends StatelessWidget {
  final bool isPlaying;
  final VideoRepeatMode repeatMode;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleAspectRatio;
  final VoidCallback onToggleRotation;

  const PlayerBottomControls({
    super.key,
    required this.isPlaying,
    required this.repeatMode,
    required this.onTogglePlay,
    required this.onNext,
    required this.onPrevious,
    required this.onToggleRepeat,
    required this.onToggleAspectRatio,
    required this.onToggleRotation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onToggleAspectRatio,
                  child: const Icon(
                    CupertinoIcons.fullscreen,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onToggleRotation,
                  child: const Icon(
                    CupertinoIcons.rotate_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onToggleRepeat,
                child: Icon(
                  _getRepeatIcon(),
                  color: repeatMode == VideoRepeatMode.off
                      ? Colors.white54
                      : Colors.white,
                  size: 28,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onPrevious,
                child: const Icon(
                  CupertinoIcons.backward_fill,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onTogglePlay,
                child: Icon(
                  isPlaying
                      ? CupertinoIcons.pause_circle_fill
                      : CupertinoIcons.play_circle_fill,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onNext,
                child: const Icon(
                  CupertinoIcons.forward_fill,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 40), // Balanced spacing
            ],
          ),
        ],
      ),
    );
  }

  IconData _getRepeatIcon() {
    switch (repeatMode) {
      case VideoRepeatMode.off:
        return CupertinoIcons.repeat;
      case VideoRepeatMode.one:
        return CupertinoIcons.repeat_1;
      case VideoRepeatMode.all:
        return CupertinoIcons.repeat;
      case VideoRepeatMode.shuffle:
        return CupertinoIcons.shuffle;
    }
  }
}
