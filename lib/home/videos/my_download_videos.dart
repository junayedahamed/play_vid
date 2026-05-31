import 'package:flutter/material.dart';
import 'package:play_vid/home/ip/view/tv_list_view.dart';
import 'package:play_vid/home/player/player.dart';
import 'package:play_vid/home/player/player_view_model/player_view_model.dart';
import 'package:play_vid/home/player/widgets/floating_audio_player.dart';
import 'package:play_vid/home/videos/widgets/video_tile.dart';
import 'package:play_vid/home/videos/view_model/local_video_fetch.dart';
import 'package:provider/provider.dart';

class MyDownloadVideos extends StatelessWidget {
  const MyDownloadVideos({super.key});

  @override
  Widget build(BuildContext context) {
    final localVideoFetch = context.watch<LocalVideoFetch>();
    final playerViewModel = context.read<PlayerViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'PLAYVID',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(
            onPressed: () => localVideoFetch.downloadVideo(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          localVideoFetch.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: localVideoFetch.videoList.length,
                  itemBuilder: (context, index) {
                    final video = localVideoFetch.videoList[index];
                    return VideoTile(
                      video: video,
                      onTap: () async {
                        playerViewModel.updateAssets(
                          localVideoFetch.videoList,
                          index,
                        );
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Player(),
                          ),
                        );
                      },
                    );
                  },
                ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: FloatingAudioPlayer(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TvListView()),
          );
        },
        child: Icon(Icons.tv_rounded),
      ),
    );
  }
}
