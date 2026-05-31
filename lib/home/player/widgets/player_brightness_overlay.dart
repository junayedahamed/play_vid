import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerBrightnessOverlay extends StatelessWidget {
  final double brightness;

  const PlayerBrightnessOverlay({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    // Determine the brightness icon based on level
    final IconData brightnessIcon = brightness < 0.3
        ? CupertinoIcons.sun_min_fill
        : brightness < 0.7
        ? CupertinoIcons.sun_haze_fill
        : CupertinoIcons.sun_max_fill;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
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
                  value: brightness,
                  backgroundColor: Colors.white12,
                  color: Colors.white,
                  strokeWidth: 6,
                ),
              ),
              // Logical grouping for icon and percentage
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(brightnessIcon, color: Colors.white, size: 28),
                  const SizedBox(height: 2),
                  Text(
                    '${(brightness * 100).toInt()}%',
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
