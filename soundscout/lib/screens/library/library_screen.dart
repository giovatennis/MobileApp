import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/album.dart';
import '../../models/load_status.dart';
import '../../providers/library_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/state_views.dart';
import '../album/album_detail_screen.dart';

/// Everything the user has saved and rated — filterable by genre, filterable
/// by minimum rating, sortable, and editable/deletable per entry.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          if (library.status == LoadStatus.loading || library.status == LoadStatus.idle) {
            return const LoadingIndicator(message: 'Loading your library...');
          }
          if (library.status == LoadStatus.error) {
            return ErrorState(
              message: library.error ?? 'Could not load your library.',
              onRetry: library.loadEntries,
            );
          }
          if (library.entries.isEmpty) {
            return const EmptyState(
              icon: Icons.library_music_outlined,
              message:
                  'Nothing saved yet. Discover a genre or search for an album, then rate it to add it here.',
            );
          }

          final entries = library.filteredSortedEntries;

          return Column(
            children: [
              _FilterBar(library: library),
              Expanded(
                child: entries.isEmpty
                    ? const EmptyState(message: 'No albums match this filter.')
                    : ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final album = Album(
                            id: entry.albumId,
                            title: entry.title,
                            artist: entry.artist,
                            coverUrl: entry.coverUrl,
                          );
                          return Dismissible(
                            key: ValueKey(entry.albumId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => library.delete(entry.albumId),
                            child: AlbumCard(
                              album: album,
                              userRating: entry.rating,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AlbumDetailScreen(
                                      album: album,
                                      discoveredGenre: entry.genre,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.library});

  final LibraryProvider library;

  @override
  Widget build(BuildContext context) {
    final availableGenres = library.availableGenres;
    final genreValue = availableGenres.contains(library.genreFilter) ? library.genreFilter : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: genreValue,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Genre',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('All genres')),
                ...availableGenres.map(
                  (g) => DropdownMenuItem<String?>(value: g, child: Text(g)),
                ),
              ],
              onChanged: library.setGenreFilter,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<LibrarySort>(
              value: library.sort,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Sort',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: LibrarySort.dateNewest, child: Text('Newest')),
                DropdownMenuItem(value: LibrarySort.dateOldest, child: Text('Oldest')),
                DropdownMenuItem(value: LibrarySort.ratingHigh, child: Text('Top rated')),
                DropdownMenuItem(value: LibrarySort.ratingLow, child: Text('Lowest rated')),
                DropdownMenuItem(value: LibrarySort.titleAZ, child: Text('Title A-Z')),
              ],
              onChanged: (value) {
                if (value != null) library.setSort(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
