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
    // Determine the speaker icon based on volume level and mute status
    final IconData speakerIcon = isMuted || volume == 0
        ? CupertinoIcons.speaker_slash_fill
        : volume < 0.3
        ? CupertinoIcons
              .speaker_1_fill // Low sound
        : volume < 0.7
        ? CupertinoIcons
              .speaker_2_fill // Medium sound
        : CupertinoIcons.speaker_3_fill; // High sound

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7), // Darker for better visibility
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring progress bar
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: volume,
                  backgroundColor: Colors.white12,
                  color: isMuted ? Colors.redAccent : Colors.white,
                  strokeWidth: 6,
                ),
              ),
              // Logical grouping for icon and percentage
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(speakerIcon, color: Colors.white, size: 28),
                  const SizedBox(height: 2),
                  Text(
                    '${(volume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
