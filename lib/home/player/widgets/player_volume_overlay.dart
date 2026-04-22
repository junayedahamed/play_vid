import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerVolumeOverlay extends StatelessWidget {
  final double volume;
  final bool showSystemUI;
  final bool isMuted;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onToggleSystemUI;
  final ValueChanged<bool> onToggleMute;

  const PlayerVolumeOverlay({
    super.key,
    required this.volume,
    required this.showSystemUI,
    required this.isMuted,
    required this.onVolumeChanged,
    required this.onToggleSystemUI,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: volume,
                  backgroundColor: Colors.white24,
                  color: isMuted ? Colors.grey : Colors.white,
                  strokeWidth: 8,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    volume == 0 || isMuted
                        ? CupertinoIcons.speaker_slash_fill
                        : volume < 0.5
                        ? CupertinoIcons.speaker_1_fill
                        : CupertinoIcons.speaker_3_fill,
                    color: Colors.white,
                    size: 32,
                  ),
                  Text(
                    '${(volume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: isMuted
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey,
                onPressed: () => onToggleMute(!isMuted),
                child: Text(isMuted ? 'Unmute' : 'Mute'),
              ),
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: showSystemUI
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey,
                onPressed: onToggleSystemUI,
                child: Text(showSystemUI ? 'Hide System UI' : 'Show System UI'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
