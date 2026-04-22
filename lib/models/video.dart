class Video {
  final String id;
  final String title;
  final String path; // Local file path or network URL
  final int duration; // Duration in milliseconds
  final bool isLocal; // true if local file, false if network URL
  String? thumbnailPath;

  Video({
    required this.id,
    required this.title,
    required this.path,
    required this.duration,
    required this.isLocal,
    this.thumbnailPath,
  });

  /// Get display duration in MM:SS format
  String get displayDuration {
    final seconds = duration ~/ 1000;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Get short title for UI display (truncate if too long)
  String get displayTitle {
    return title.length > 30 ? '${title.substring(0, 27)}...' : title;
  }

  @override
  String toString() =>
      'Video(id: $id, title: $title, duration: $displayDuration, isLocal: $isLocal)';
}
