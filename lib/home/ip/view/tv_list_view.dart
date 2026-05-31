import 'package:flutter/material.dart';
import 'package:play_vid/data/ip_tv_model.dart';
import 'package:play_vid/home/ip/view/ip_tv_view.dart';
import 'package:play_vid/home/ip/view_model/ip_view_model.dart';

class TvListView extends StatelessWidget {
  TvListView({super.key});
  final IpViewModel viewModel = IpViewModel();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TV List'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Sports'),
              Tab(text: 'News'),
              Tab(text: 'Movies'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.tvList.isEmpty) {
              return const Center(child: Text('No TV channels available'));
            }

            final allTv = viewModel.tvList
                .where((tv) => tv.url != null)
                .toList();

            return TabBarView(
              children: [
                _buildGrid(allTv),
                _buildGrid(
                  _filterByCategory(allTv, [
                    'sport',
                    'soccer',
                    'cricket',
                    'football',
                  ]),
                ),
                _buildGrid(
                  _filterByCategory(allTv, ['news', 'business', 'weather']),
                ),
                _buildGrid(
                  _filterByCategory(allTv, [
                    'movie',
                    'series',
                    'film',
                    'cinema',
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

  Widget _buildGrid(List<IpTvModel> channels) {
    if (channels.isEmpty) {
      return const Center(child: Text('No channels found in this category'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: channels.length,
      itemBuilder: (context, index) {
        final tv = channels[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IpTvView(url: tv.url!)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        _getIconForTitle(tv.title ?? tv.channel ?? ''),
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tv.title ?? tv.channel ?? 'Unknown',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quality: ${tv.quality ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('news')) return Icons.article;
    if (lower.contains('sport') || lower.contains('football')) {
      return Icons.sports_soccer;
    }
    if (lower.contains('movie') || lower.contains('cinema')) return Icons.movie;
    if (lower.contains('music')) return Icons.music_note;
    return Icons.tv;
  }
}
