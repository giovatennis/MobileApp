import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_status.dart';
import '../../providers/discover_provider.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/niche_genre_chip.dart';
import '../../widgets/state_views.dart';
import 'genre_detail_screen.dart';
import 'niche_genre_detail_screen.dart';

/// Entry point of the Discover tab. Two sections: Deezer's broad top-level
/// genres (Pop, Rock, Jazz...) and a hand-curated set of niche/deep-cut
/// genres (shoegaze, neo-psychedelia, city pop...) that a broad catalog
/// genre list wouldn't otherwise surface.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Consumer<DiscoverProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              _sectionHeader(context, 'Popular Genres'),
              _buildPopularSection(context, provider),
              _sectionHeader(
                context,
                'Niche & Deep Cuts',
                subtitle: 'Lesser-known genres worth exploring, curated by hand.',
              ),
              _buildNicheSection(context, provider),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, {String? subtitle}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context, DiscoverProvider provider) {
    if (provider.genresStatus == LoadStatus.idle || provider.genresStatus == LoadStatus.loading) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 140, child: LoadingIndicator(message: 'Loading genres...')),
      );
    }
    if (provider.genresStatus == LoadStatus.error) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 160,
          child: ErrorState(
            message: provider.genresError ?? 'Something went wrong.',
            onRetry: provider.loadGenres,
          ),
        ),
      );
    }
    if (provider.genres.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 100, child: EmptyState(message: 'No genres available right now.')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: _gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final genre = provider.genres[index];
            return GenreChip(
              genre: genre,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GenreDetailScreen(genre: genre)),
                );
              },
            );
          },
          childCount: provider.genres.length,
        ),
      ),
    );
  }

  Widget _buildNicheSection(BuildContext context, DiscoverProvider provider) {
    if (provider.nicheGenresStatus == LoadStatus.idle ||
        provider.nicheGenresStatus == LoadStatus.loading) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 140, child: LoadingIndicator(message: 'Loading niche genres...')),
      );
    }
    if (provider.nicheGenresStatus == LoadStatus.error) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 160,
          child: ErrorState(
            message: provider.nicheGenresError ?? 'Something went wrong.',
            onRetry: provider.loadNicheGenres,
          ),
        ),
      );
    }
    if (provider.nicheGenres.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(height: 100, child: EmptyState(message: 'No niche genres available right now.')),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: _gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final genre = provider.nicheGenres[index];
            return NicheGenreChip(
              genre: genre,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NicheGenreDetailScreen(genre: genre)),
                );
              },
            );
          },
          childCount: provider.nicheGenres.length,
        ),
      ),
    );
  }
}
