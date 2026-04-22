import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/video.dart';

class VideoService {
  static const _videoExtensions = [
    'mp4',
    'mkv',
    'webm',
    'avi',
    'mov',
    'flv',
    'wmv',
    '3gp',
  ];

  /// Request photo/video access permission
  static Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  /// Check if permission is already granted
  static Future<bool> hasPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  /// Fetch all local videos from device storage
  static Future<List<Video>> fetchLocalVideos() async {
    try {
      final bool hasPermission = await requestPermission();
      if (!hasPermission) {
        return [];
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      List<Video> videos = [];
      int videoId = 0;

      for (final path in paths) {
        final entities = await path.getAssetListRange(start: 0, end: 999999);
        for (final entity in entities) {
          try {
            final file = await entity.file;
            if (file != null) {
              videos.add(
                Video(
                  id: 'local_${videoId++}',
                  title: entity.title ?? file.path.split('/').last,
                  path: file.path,
                  duration: entity.duration * 1000, // Convert to milliseconds
                  isLocal: true,
                  thumbnailPath: null,
                ),
              );
            }
          } catch (e) {
            print('Error loading video: $e');
          }
        }
      }

      return videos;
    } catch (e) {
      print('Error fetching videos: $e');
      return [];
    }
  }

  /// Generate thumbnail for a video
  static Future<String?> getVideoThumbnail(String videoPath) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxHeight: 200,
        maxWidth: 300,
        quality: 75,
      );
      return uint8list != null ? videoPath : null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Validate if file is a video by extension
  static bool isVideoFile(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return _videoExtensions.contains(ext);
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable size
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int index = 0;

    while (size > 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }
}
