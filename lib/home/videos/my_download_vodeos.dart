import 'package:flutter/material.dart';
import 'package:play_vid/home/player/player.dart';
import 'package:play_vid/home/player/player_view_model/player_view_model.dart';
import 'package:play_vid/home/player/widgets/floating_audio_player.dart';
import 'package:play_vid/home/videos/widgets/song_tile.dart';
import 'package:play_vid/home/videos/view_model/local_video_fetch.dart';
import 'package:provider/provider.dart';

class MyDownloadVodeos extends StatelessWidget {
  const MyDownloadVodeos({super.key});

  @override
  Widget build(BuildContext context) {
    final localVideoFetch = context.watch<LocalVideoFetch>();
    final playerViewModel = context.read<PlayerViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Download Videos')),
      body: Stack(
        children: [
          localVideoFetch.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: localVideoFetch.videoList.length,
                  itemBuilder: (context, index) {
                    final video = localVideoFetch.videoList[index];
                    return SongTile(
                      song: video,
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
    );
  }
}
