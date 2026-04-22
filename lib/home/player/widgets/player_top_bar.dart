import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onAudioSettings;
  final VoidCallback onBackgroundPlay;

  const PlayerTopBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onAudioSettings,
    required this.onBackgroundPlay,
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
              onPressed: onAudioSettings,
              child: const Icon(
                CupertinoIcons.speaker_2,
                color: Colors.white,
                size: 24,
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
          ],
        ),
      ),
    );
  }
}
