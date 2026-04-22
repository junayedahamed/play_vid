import 'package:flutter/material.dart';
import 'package:play_vid/home/player/player.dart';
import 'package:play_vid/home/view_model/local_video_fetch.dart';

class MyDownloadVodeos extends StatelessWidget {
  const MyDownloadVodeos({super.key, required this.localVideoFetch});
  final LocalVideoFetch localVideoFetch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Download Videos')),
      body: ListenableBuilder(
        listenable: localVideoFetch,

        builder: (context, asyncSnapshot) {
          return localVideoFetch.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: localVideoFetch.videoList.length,
                  itemBuilder: (context, index) {
                    final video = localVideoFetch.videoList[index];
                    return ListTile(
                      onTap: () async {
                        final file = await video.file;
                        if (file == null) return;
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Player(
                              assetEntitys: localVideoFetch.videoList,
                              filepath: file.path,
                              currentIndex: index,
                            ),
                          ),
                        );
                      },
                      title: Text('Video ${video.title}'),
                    );
                  },
                );
        },
      ),
    );
  }
}
