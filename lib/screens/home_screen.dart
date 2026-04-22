import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:play_vid/services/video_service.dart';
import 'package:play_vid/providers/video_provider.dart';
import 'package:play_vid/models/video.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Video>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = VideoService.fetchLocalVideos();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Videos'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _refreshVideos(),
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<List<Video>>(
          future: _videosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(radius: 15),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: CupertinoActionSheetAction(
                  onPressed: () => _refreshVideos(),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final videos = snapshot.data ?? [];

            if (videos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.film,
                      size: 60,
                      color: CupertinoColors.systemGrey3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No videos found',
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CupertinoButton.filled(
                      onPressed: () => _refreshVideos(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            // Update video provider with fetched videos
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<VideoProvider>().setVideoList(videos);
            });

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return _buildVideoCard(context, videos[index], index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Video video, int index) {
    return GestureDetector(
      onTap: () {
        context.read<VideoProvider>().setCurrentIndex(index);
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (context) => const VideoPlayerScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder / Thumbnail
            Container(
              color: CupertinoColors.systemGrey4,
              child: const Center(
                child: Icon(
                  CupertinoIcons.film_fill,
                  size: 40,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            // Video info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      CupertinoColors.black.withOpacity(0),
                      CupertinoColors.black.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video.displayDuration,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey4,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Play icon overlay
            const Center(
              child: Icon(
                CupertinoIcons.play_circle_fill,
                size: 40,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshVideos() {
    setState(() {
      _videosFuture = VideoService.fetchLocalVideos();
    });
  }
}
