import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/album.dart';
import '../../providers/discover_provider.dart';
import '../../providers/library_provider.dart';
import '../../services/deezer_api_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/state_views.dart';

/// Album detail + the app's core interaction: rate it, tag it with a genre,
/// optionally write a review, and save it to (or remove it from) the local
/// library. [discoveredGenre] pre-fills the genre field when arriving from
/// the Discover flow or from an existing library entry.
class AlbumDetailScreen extends StatefulWidget {
  const AlbumDetailScreen({super.key, required this.album, this.discoveredGenre});

  final Album album;
  final String? discoveredGenre;

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final _api = DeezerApiService();

  Album? _fullAlbum;
  bool _loadingDetail = true;
  String? _detailError;

  int _rating = 0;
  late final TextEditingController _reviewController;
  String? _selectedGenre;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _selectedGenre = widget.discoveredGenre;
    _loadDetail();
  }

  void _hydrateFromLibraryIfNeeded(LibraryProvider library) {
    if (_hydrated) return;
    _hydrated = true;
    final existing = library.entryForAlbum(widget.album.id);
    if (existing != null) {
      _rating = existing.rating;
      _reviewController.text = existing.review;
      _selectedGenre = existing.genre;
    }
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true;
      _detailError = null;
    });
    try {
      final full = await _api.getAlbumDetail(widget.album.id);
      if (!mounted) return;
      setState(() {
        _fullAlbum = full;
        _loadingDetail = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _detailError = e.toString();
        _loadingDetail = false;
      });
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _save(BuildContext context) async {
    final library = context.read<LibraryProvider>();
    await library.saveOrUpdate(
      album: _fullAlbum ?? widget.album,
      genre: _selectedGenre!,
      rating: _rating,
      review: _reviewController.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your library.')),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final library = context.read<LibraryProvider>();
    await library.delete(widget.album.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from your library.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final album = _fullAlbum ?? widget.album;
    final library = context.watch<LibraryProvider>();
    _hydrateFromLibraryIfNeeded(library);
    final isSaved = library.isSaved(widget.album.id);

    // Combines Deezer's broad genres with the curated niche genre list, so an
    // album discovered under a niche genre (e.g. "Shoegaze") can actually be
    // tagged and later filtered by that name in the Library. Already
    // de-duplicated/sorted by the provider — DropdownButtonFormField throws
    // if more than one item shares its value.
    final discoverGenres = context.watch<DiscoverProvider>().allGenreNames;
    // Guard against pointing the dropdown at a value that isn't (yet, or no
    // longer) in the loaded genre list — Flutter throws if a
    // DropdownButtonFormField's value doesn't match exactly one item.
    final dropdownValue = discoverGenres.contains(_selectedGenre) ? _selectedGenre : null;

    return Scaffold(
      appBar: AppBar(title: Text(album.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: album.coverUrl.isNotEmpty
                  ? Image.network(
                      album.coverUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.album, size: 48, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.album, size: 48, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            album.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            album.artist,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (album.releaseDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Released ${album.releaseDate}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 20),
          if (_loadingDetail)
            const LoadingIndicator(message: 'Loading tracklist...')
          else if (_detailError != null)
            ErrorState(message: _detailError!, onRetry: _loadDetail)
          else if (album.tracklist != null && album.tracklist!.isNotEmpty) ...[
            Text('Tracklist', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...album.tracklist!.asMap().entries.map(
                  (entry) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Text('${entry.key + 1}'),
                    title: Text(entry.value.title, overflow: TextOverflow.ellipsis),
                    trailing: Text(_formatDuration(entry.value.duration)),
                  ),
                ),
          ],
          const Divider(height: 32),
          Text('Your Rating', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Center(
            child: StarRating(
              rating: _rating,
              editable: true,
              size: 36,
              onChanged: (r) => setState(() => _rating = r),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: dropdownValue,
            decoration: const InputDecoration(
              labelText: 'Genre',
              border: OutlineInputBorder(),
            ),
            items: discoverGenres
                .map((name) => DropdownMenuItem(value: name, child: Text(name)))
                .toList(),
            onChanged: (value) => setState(() => _selectedGenre = value),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Your review (optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _rating == 0 || _selectedGenre == null ? null : () => _save(context),
            icon: const Icon(Icons.check),
            label: Text(isSaved ? 'Update in Library' : 'Save to Library'),
          ),
          if (isSaved) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Remove from Library', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
