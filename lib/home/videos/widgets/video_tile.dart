import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({super.key, required this.video, this.onTap});
  final AssetEntity video;
  final VoidCallback? onTap;

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return "${duration.inHours}:${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    }
    return "${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return "${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Section
                Stack(
                  children: [
                    Container(
                      width: 110,
                      height: 70,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FutureBuilder(
                        future: video.thumbnailDataWithSize(
                          const ThumbnailSize(300, 200),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: 110,
                                height: 70,
                              ),
                            );
                          }
                          return Shimmer.fromColors(
                            baseColor: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.1),
                            highlightColor: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.05),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Play duration overlay
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(Duration(seconds: video.duration)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title ?? 'No Name Video',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Meta info row
                      Row(
                        children: [
                          _buildMetaData(
                            context,
                            Icons.folder_outlined,
                            FutureBuilder<File?>(
                              future: video.file,
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                    _formatSize(snapshot.data!.lengthSync()),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  );
                                }
                                return Text(
                                  "...",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildMetaData(
                            context,
                            Icons.calendar_today_outlined,
                            Text(
                              "${video.createDateTime.day}/${video.createDateTime.month}/${video.createDateTime.year}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Action Menu
                // IconButton(
                //   onPressed: () {
                //     //
                //   },
                //   icon: Icon(
                //     Icons.more_vert,
                //     color: theme.hintColor.withValues(alpha: 0.6),
                //     size: 20,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaData(BuildContext context, IconData icon, Widget text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        text,
      ],
    );
  }
}
