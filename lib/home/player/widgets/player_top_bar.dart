import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerTopBar extends StatelessWidget {
  final String title;
  final double playbackSpeed;
  final VoidCallback onBack;
  final VoidCallback onAudioSettings;
  final VoidCallback onBackgroundPlay;
  final ValueChanged<double> onPlaybackSpeedChanged;

  const PlayerTopBar({
    super.key,
    required this.title,
    required this.playbackSpeed,
    required this.onBack,
    required this.onAudioSettings,
    required this.onBackgroundPlay,
    required this.onPlaybackSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              child: const Icon(
                CupertinoIcons.back,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showSpeedMenu(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${playbackSpeed}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBackgroundPlay,
              child: const Icon(
                CupertinoIcons.headphones,
                color: Colors.white,
                size: 24,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAudioSettings,
              child: const Icon(
                CupertinoIcons.speaker_2,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Playback Speed'),
        actions: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
          return CupertinoActionSheetAction(
            onPressed: () {
              onPlaybackSpeedChanged(speed);
              Navigator.pop(context);
            },
            child: Text('${speed}x'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
