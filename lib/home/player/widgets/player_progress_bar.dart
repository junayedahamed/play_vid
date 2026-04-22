import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final String Function(Duration) formatDuration;

  const PlayerProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final double value = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double horizontalPadding = isLandscape ? 24.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            width: double.infinity,
            child: CupertinoSlider(
              activeColor: CupertinoColors.systemRed,
              thumbColor: CupertinoColors.systemRed,
              value: value,
              onChanged: onSeek,
            ),
          ),
        ],
      ),
    );
  }
}
