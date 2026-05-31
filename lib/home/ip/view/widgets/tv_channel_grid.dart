import 'package:flutter/material.dart';
import 'package:play_vid/data/ip_tv_model.dart';
import 'tv_channel_card.dart';

class TvChannelGrid extends StatelessWidget {
  final List<IpTvModel> channels;

  const TvChannelGrid({super.key, required this.channels});

  @override
  Widget build(BuildContext context) {
    if (channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off_rounded,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No channels found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        return TvChannelCard(
          tv: channels[index],
          channels: channels,
          index: index,
        );
      },
    );
  }
}
