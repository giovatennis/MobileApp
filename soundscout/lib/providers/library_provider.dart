import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../models/library_entry.dart';
import '../models/load_status.dart';
import '../services/database_service.dart';

enum LibrarySort { dateNewest, dateOldest, ratingHigh, ratingLow, titleAZ }

/// State for the Library and Stats tabs, and the single source of truth for
/// "has the user already rated this album." Owns all read/write access to
/// the local database.
class LibraryProvider extends ChangeNotifier {
  LibraryProvider({DatabaseService? db}) : _db = db ?? DatabaseService.instance;

  final DatabaseService _db;

  List<LibraryEntry> _entries = [];
  LoadStatus status = LoadStatus.idle;
  String? error;

  String? genreFilter;
  int minRatingFilter = 0;
  LibrarySort sort = LibrarySort.dateNewest;

  List<LibraryEntry> get entries => _entries;

  Future<void> loadEntries() async {
    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      _entries = await _db.getAllEntries();
      // If a genre filter no longer has any matching entries (e.g. its last
      // album was just deleted), drop it rather than risk pointing at a
      // genre that no longer exists in the current entry set.
      if (genreFilter != null && !_entries.any((e) => e.genre == genreFilter)) {
        genreFilter = null;
      }
      status = LoadStatus.loaded;
    } catch (e) {
      error = e.toString();
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  List<String> get availableGenres {
    final set = _entries.map((e) => e.genre).toSet().toList();
    set.sort();
    return set;
  }

  List<LibraryEntry> get filteredSortedEntries {
    final list = _entries.where((e) {
      if (genreFilter != null && e.genre != genreFilter) return false;
      if (e.rating < minRatingFilter) return false;
      return true;
    }).toList();

    switch (sort) {
      case LibrarySort.dateNewest:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case LibrarySort.dateOldest:
        list.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case LibrarySort.ratingHigh:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case LibrarySort.ratingLow:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case LibrarySort.titleAZ:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  void setGenreFilter(String? genre) {
    genreFilter = genre;
    notifyListeners();
  }

  void setMinRatingFilter(int rating) {
    minRatingFilter = rating;
    notifyListeners();
  }

  void setSort(LibrarySort newSort) {
    sort = newSort;
    notifyListeners();
  }

  LibraryEntry? entryForAlbum(int albumId) {
    for (final e in _entries) {
      if (e.albumId == albumId) return e;
    }
    return null;
  }

  bool isSaved(int albumId) => entryForAlbum(albumId) != null;

  Future<void> saveOrUpdate({
    required Album album,
    required String genre,
    required int rating,
    required String review,
  }) async {
    final existing = entryForAlbum(album.id);
    final entry = LibraryEntry(
      albumId: album.id,
      title: album.title,
      artist: album.artist,
      coverUrl: album.coverUrl,
      genre: genre,
      rating: rating,
      review: review,
      dateAdded: existing?.dateAdded ?? DateTime.now(),
    );
    await _db.upsertEntry(entry);
    await loadEntries();
  }

  Future<void> delete(int albumId) async {
    await _db.deleteEntryByAlbumId(albumId);
    await loadEntries();
  }

  // ---- Stats helpers (consumed by the Stats screen / fl_chart widgets) ----

  Map<String, double> get avgRatingByGenre {
    final Map<String, List<int>> grouped = {};
    for (final e in _entries) {
      grouped.putIfAbsent(e.genre, () => []).add(e.rating);
    }
    return grouped.map((genre, ratings) {
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return MapEntry(genre, avg);
    });
  }

  Map<int, int> get ratingDistribution {
    final Map<int, int> dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final e in _entries) {
      dist[e.rating] = (dist[e.rating] ?? 0) + 1;
    }
    return dist;
  }

  /// Keys are "YYYY-MM", sorted chronologically by the caller.
  Map<String, int> get entriesPerMonth {
    final Map<String, int> counts = {};
    for (final e in _entries) {
      final key = '${e.dateAdded.year}-${e.dateAdded.month.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }
}
