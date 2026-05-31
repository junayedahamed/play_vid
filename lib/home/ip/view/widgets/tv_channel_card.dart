import 'package:flutter/material.dart';
import 'package:play_vid/data/ip_tv_model.dart';
import 'package:play_vid/home/ip/view/ip_player.dart';
import 'package:play_vid/home/ip/view_model/view_model.dart';
import 'package:provider/provider.dart';

class TvChannelCard extends StatelessWidget {
  final IpTvModel tv;
  final List<IpTvModel> channels;
  final int index;

  const TvChannelCard({
    super.key,
    required this.tv,
    required this.channels,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final channelName = tv.title ?? tv.channel ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => IPplayerViewModel(
                      channels: channels,
                      currentIndex: index,
                    ),
                    child: const IpPlayer(),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getCategoryColor(
                                channelName,
                              ).withValues(alpha: 0.8),
                              _getCategoryColor(channelName),
                            ],
                          ),
                        ),
                        child: Icon(
                          _getIconForTitle(channelName),
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tv.quality?.toUpperCase() ?? 'HD',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.live_tv_rounded,
                            size: 14,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Live Stream',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('news')) return Colors.blueGrey;
    if (lower.contains('sport') || lower.contains('football')) {
      return Colors.green.shade700;
    }
    if (lower.contains('movie') || lower.contains('cinema')) {
      return Colors.deepOrange.shade700;
    }
    if (lower.contains('music')) return Colors.purple.shade700;
    return Colors.indigo.shade700;
  }

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('news')) return Icons.article_rounded;
    if (lower.contains('sport') || lower.contains('football')) {
      return Icons.sports_soccer_rounded;
    }
    if (lower.contains('movie') || lower.contains('cinema')) {
      return Icons.movie_filter_rounded;
    }
    if (lower.contains('music')) return Icons.music_note_rounded;
    return Icons.tv_rounded;
  }
}
