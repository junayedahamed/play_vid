import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DownloadvideoFetch extends ChangeNotifier {
  List<AssetEntity> videoList = [];
  bool isLoading = false;

  Future<void> downloadVideo() async {
    isLoading = true;
    notifyListeners();

    try {
      // Request permission to access files
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth) {
        // Fetch all video albums
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(type: RequestType.video);

        if (albums.isNotEmpty) {
          // Fetch all videos from all albums or just the "Recent" one (usually the first)
          final List<AssetEntity> allVideos = [];
          for (var album in albums) {
            final List<AssetEntity> videos = await album.getAssetListRange(
              start: 0,
              end: await album.assetCountAsync,
            );
            allVideos.addAll(videos);
          }
          videoList = allVideos;
        }
      } else {
        // Handle permission denied
        PhotoManager.openSetting();
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
