import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/genre.dart';
import '../../models/load_status.dart';
import '../../providers/discover_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/state_views.dart';
import '../album/album_detail_screen.dart';

/// Shows a genre's description followed by its current chart albums —
/// this is the actual "discovery" surface of the app.
class GenreDetailScreen extends StatefulWidget {
  const GenreDetailScreen({super.key, required this.genre});

  final Genre genre;

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiscoverProvider>().selectGenre(widget.genre);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.genre.name)),
      body: Consumer2<DiscoverProvider, LibraryProvider>(
        builder: (context, discover, library, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    discover.descriptionFor(widget.genre),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Divider(),
                ),
              ),
              _buildChartSliver(context, discover, library),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartSliver(BuildContext context, DiscoverProvider discover, LibraryProvider library) {
    if (discover.chartStatus == LoadStatus.idle || discover.chartStatus == LoadStatus.loading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingIndicator(message: 'Loading albums...'),
      );
    }
    if (discover.chartStatus == LoadStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: discover.chartError ?? 'Could not load albums for this genre.',
          onRetry: () => discover.selectGenre(widget.genre),
        ),
      );
    }
    if (discover.chartAlbums.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(message: 'No albums found for this genre yet.'),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final album = discover.chartAlbums[index];
          final existing = library.entryForAlbum(album.id);
          return AlbumCard(
            album: album,
            userRating: existing?.rating,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AlbumDetailScreen(
                    album: album,
                    discoveredGenre: widget.genre.name,
                  ),
                ),
              );
            },
          );
        },
        childCount: discover.chartAlbums.length,
      ),
    );
  }
}
