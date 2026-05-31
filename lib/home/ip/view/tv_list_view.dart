import 'package:flutter/material.dart';
import 'package:play_vid/data/ip_tv_model.dart';
import 'package:play_vid/home/ip/view_model/ip_view_model.dart';
import 'package:play_vid/home/ip/view/widgets/tv_channel_grid.dart';

class TvListView extends StatelessWidget {
  TvListView({super.key});
  final IpViewModel viewModel = IpViewModel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            'IPTV STREAMS',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search_rounded),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
            ),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: theme.colorScheme.primary,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              ),
            ),
            tabs: const [
              Tab(text: 'ALL CHANNELS'),
              Tab(text: 'SPORTS'),
              Tab(text: 'NEWS'),
              Tab(text: 'MOVIES'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Fetching streams...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            }

            final allTv = viewModel.tvList
                .where((tv) => tv.url != null && tv.quality != null)
                .toList();

            if (allTv.isEmpty && !viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                      size: 64,
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No TV channels available',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => viewModel.getTvList(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                TvChannelGrid(channels: allTv),
                TvChannelGrid(
                  channels: _filterByCategory(allTv, [
                    'sport',
                    'soccer',
                    'cricket',
                    'football',
                    'espn',
                    'beingsport',
                  ]),
                ),
                TvChannelGrid(
                  channels: _filterByCategory(allTv, [
                    'news',
                    'business',
                    'weather',
                    'cnn',
                    'bbc',
                    'al jazeera',
                  ]),
                ),
                TvChannelGrid(
                  channels: _filterByCategory(allTv, [
                    'movie',
                    'series',
                    'film',
                    'cinema',
                    'hbo',
                    'netflix',
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<IpTvModel> _filterByCategory(
    List<IpTvModel> list,
    List<String> keywords,
  ) {
    return list.where((tv) {
      final text = (tv.title ?? tv.channel ?? '').toLowerCase();
      return keywords.any((keyword) => text.contains(keyword));
    }).toList();
  }
}
