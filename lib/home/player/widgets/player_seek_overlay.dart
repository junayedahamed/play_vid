import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlayerSeekOverlay extends StatelessWidget {
  final Duration seekOffset;

  const PlayerSeekOverlay({super.key, required this.seekOffset});

  @override
  Widget build(BuildContext context) {
    final bool isForward = seekOffset.inSeconds >= 0;
    final String sign = isForward ? "+" : "-";
    final int seconds = seekOffset.inSeconds.abs();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isForward
                ? CupertinoIcons.forward_fill
                : CupertinoIcons.backward_fill,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            '$sign${seconds}s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
