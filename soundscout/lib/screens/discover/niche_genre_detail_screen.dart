import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_status.dart';
import '../../models/niche_genre.dart';
import '../../providers/discover_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/state_views.dart';
import '../album/album_detail_screen.dart';

/// Shows a curated niche genre's description plus its hand-picked seed
/// albums, resolved live against Deezer for real cover art/IDs.
class NicheGenreDetailScreen extends StatefulWidget {
  const NicheGenreDetailScreen({super.key, required this.genre});

  final NicheGenre genre;

  @override
  State<NicheGenreDetailScreen> createState() => _NicheGenreDetailScreenState();
}

class _NicheGenreDetailScreenState extends State<NicheGenreDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DiscoverProvider>().selectNicheGenre(widget.genre);
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
                    widget.genre.description,
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
              _buildAlbumsSliver(context, discover, library),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlbumsSliver(BuildContext context, DiscoverProvider discover, LibraryProvider library) {
    if (discover.nicheAlbumsStatus == LoadStatus.idle || discover.nicheAlbumsStatus == LoadStatus.loading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingIndicator(message: 'Finding albums...'),
      );
    }
    if (discover.nicheAlbumsStatus == LoadStatus.error) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: discover.nicheAlbumsError ?? 'Could not load albums for this genre.',
          onRetry: () => discover.selectNicheGenre(widget.genre),
        ),
      );
    }
    if (discover.nicheAlbums.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(message: "Couldn't find these albums on Deezer right now."),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final album = discover.nicheAlbums[index];
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
        childCount: discover.nicheAlbums.length,
      ),
    );
  }
}
