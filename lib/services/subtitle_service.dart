import 'dart:io';
import 'package:path/path.dart' as p;

class SubtitleService {
  static const _subtitleExtensions = ['srt', 'vtt', 'sub', 'ass', 'ssa'];

  /// Get available subtitle files from device storage
  static Future<List<String>> getAvailableSubtitles(String videoPath) async {
    try {
      final videoDir = Directory(File(videoPath).parent.path);
      final videoName = p.basenameWithoutExtension(videoPath);

      List<String> subtitles = [];

      if (await videoDir.exists()) {
        final files = videoDir.listSync();
        for (final file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last;
            final ext = fileName.split('.').last.toLowerCase();
            final name = fileName.replaceAll(RegExp(r'\.\w+$'), '');

            // Match subtitles with same name as video or generic subtitle names
            if (_subtitleExtensions.contains(ext) &&
                (name == videoName ||
                    name.contains('subtitle') ||
                    name.contains('sub'))) {
              subtitles.add(file.path);
            }
          }
        }
      }

      return subtitles;
    } catch (e) {
      print('Error getting subtitles: $e');
      return [];
    }
  }

  /// Get all subtitle files from a directory
  static Future<List<String>> getAllSubtitles(String directoryPath) async {
    try {
      final dir = Directory(directoryPath);
      List<String> subtitles = [];

      if (await dir.exists()) {
        final files = dir.listSync();
        for (final file in files) {
          if (file is File) {
            final ext = file.path.split('.').last.toLowerCase();
            if (_subtitleExtensions.contains(ext)) {
              subtitles.add(file.path);
            }
          }
        }
      }

      return subtitles;
    } catch (e) {
      print('Error getting all subtitles: $e');
      return [];
    }
  }

  /// Check if file is a valid subtitle file
  static bool isSubtitleFile(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return _subtitleExtensions.contains(ext);
  }

  /// Get subtitle file name without path
  static String getSubtitleName(String filePath) {
    return filePath.split('/').last;
  }
}
