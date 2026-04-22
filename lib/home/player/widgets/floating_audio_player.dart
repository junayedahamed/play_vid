import 'package:flutter/material.dart';
import 'package:play_vid/home/player/player.dart';
import 'package:play_vid/home/player/player_view_model/player_view_model.dart';
import 'package:provider/provider.dart';

class FloatingAudioPlayer extends StatelessWidget {
  const FloatingAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlayerViewModel>();

    if (!viewModel.isBackgroundPlay || !viewModel.isInitialized) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        viewModel.exitBackgroundMode(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Player()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: LinearProgressIndicator(
                value: viewModel.controller.value.duration.inMilliseconds > 0
                    ? viewModel.controller.value.position.inMilliseconds /
                          viewModel.controller.value.duration.inMilliseconds
                    : 0,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple,
                ),
                minHeight: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.headset, color: Colors.white70, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.currentTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Background Audio Mode",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: viewModel.playPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      viewModel.controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: viewModel.togglePlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: viewModel.playNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
