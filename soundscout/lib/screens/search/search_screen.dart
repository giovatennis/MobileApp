import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_status.dart';
import '../../providers/library_provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/album_card.dart';
import '../../widgets/state_views.dart';
import '../album/album_detail_screen.dart';

/// Direct search by artist or album name — the counterpart to genre-based
/// Discover, for when the user already knows what they're looking for.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<SearchProvider>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search albums or artists...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Consumer2<SearchProvider, LibraryProvider>(
        builder: (context, search, library, _) {
          if (search.status == LoadStatus.idle) {
            return const EmptyState(
              icon: Icons.search,
              message: 'Search for an artist or album to get started.',
            );
          }
          if (search.status == LoadStatus.loading) {
            return const LoadingIndicator(message: 'Searching...');
          }
          if (search.status == LoadStatus.error) {
            return ErrorState(
              message: search.error ?? 'Search failed.',
              onRetry: () => search.search(search.query),
            );
          }
          if (search.results.isEmpty) {
            return const EmptyState(message: 'No results found. Try a different search.');
          }
          return ListView.builder(
            itemCount: search.results.length,
            itemBuilder: (context, index) {
              final album = search.results[index];
              final existing = library.entryForAlbum(album.id);
              return AlbumCard(
                album: album,
                userRating: existing?.rating,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
