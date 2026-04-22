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
      padding: const EdgeInsets.all(20),
      color: Colors.black54,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                volume == 0 || isMuted
                    ? CupertinoIcons.speaker_slash_fill
                    : volume < 0.5
                    ? CupertinoIcons.speaker_1_fill
                    : CupertinoIcons.speaker_3_fill,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CupertinoSlider(
                  value: volume,
                  onChanged: onVolumeChanged,
                ),
              ),
              Text(
                '${(volume * 100).toInt()}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: isMuted
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey,
                onPressed: () => onToggleMute(!isMuted),
                child: Text(isMuted ? 'Unmute' : 'Mute'),
              ),
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
