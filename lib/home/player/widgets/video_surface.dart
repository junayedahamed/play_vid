import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../player_view_model/player_view_model.dart';

class VideoSurface extends StatelessWidget {
  final PlayerViewModel viewModel;

  const VideoSurface({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Toggle overlay on tap anywhere
      onTap: viewModel.handleTap,
      // Vertical drag for Volume (left) and Brightness (right)
      onVerticalDragStart: (details) {
        final box = context.findRenderObject() as RenderBox;
        viewModel.onVerticalDragStart(details, box.size.width);
      },
      onVerticalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        viewModel.onVerticalDragUpdate(details, box.size.height);
      },
      onVerticalDragEnd: viewModel.onVerticalDragEnd,
      // Horizontal drag for Seek in center/anywhere
      onHorizontalDragStart: viewModel.onHorizontalDragStart,
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        viewModel.onHorizontalDragUpdate(details, box.size.width);
      },
      onHorizontalDragEnd: viewModel.onHorizontalDragEnd,
      child: Container(
        // Making the container expand to fill the screen
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: viewModel.isInitialized
              ? AspectRatio(
                  aspectRatio: viewModel.currentAspectRatio ??
                      viewModel.controller.value.aspectRatio,
                  child: VideoPlayer(viewModel.controller),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
