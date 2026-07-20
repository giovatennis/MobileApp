import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/album.dart';
import '../models/genre.dart';

/// Thrown for any failure talking to the Deezer API — network failure,
/// non-200 response, or an error object embedded in an otherwise-200 body
/// (Deezer often returns HTTP 200 with an {"error": {...}} payload instead
/// of a proper HTTP error status).
class DeezerApiException implements Exception {
  final String message;
  DeezerApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the public Deezer API (https://api.deezer.com).
/// No API key is required — it's a read-only public catalog API.
class DeezerApiService {
  static const String _baseUrl = 'https://api.deezer.com';
  static const Duration _timeout = Duration(seconds: 12);

  Future<dynamic> _get(Uri uri) async {
    late final http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } catch (_) {
      throw DeezerApiException(
        'Could not reach Deezer. Check your internet connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw DeezerApiException('Request failed (HTTP ${response.statusCode}).');
    }

    dynamic decoded;
    try {
      decoded = json.decode(response.body);
    } catch (_) {
      throw DeezerApiException('Received an unexpected response from Deezer.');
    }

    if (decoded is Map && decoded.containsKey('error')) {
      final err = decoded['error'];
      final message = (err is Map ? err['message']?.toString() : null) ?? 'Unknown API error.';
      throw DeezerApiException(message);
    }

    return decoded;
  }

  /// Top-level music genres, e.g. Pop, Rock, Rap/Hip Hop, Electro...
  Future<List<Genre>> getGenres() async {
    final body = await _get(Uri.parse('$_baseUrl/genre')) as Map<String, dynamic>;
    final data = (body['data'] as List?) ?? [];
    return data
        .whereType<Map>()
        .map((g) => Genre.fromJson(Map<String, dynamic>.from(g)))
        // id 0 is Deezer's "All genres" pseudo-entry — not useful as a browsable genre.
        .where((g) => g.id != 0)
        .toList();
  }

  /// Top albums currently charting within a given genre. Deezer's default
  /// page size is small (~25), so [limit] defaults higher to give the
  /// Discover screen a deeper list without extra pagination UI.
  Future<List<Album>> getGenreChartAlbums(int genreId, {int limit = 50}) async {
    final uri = Uri.parse('$_baseUrl/chart/$genreId/albums')
        .replace(queryParameters: {'limit': '$limit'});
    final body = await _get(uri) as Map<String, dynamic>;
    final data = (body['data'] as List?) ?? [];
    return data
        .whereType<Map>()
        .map((a) => Album.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  /// Direct search by artist or album name.
  Future<List<Album>> searchAlbums(String query) async {
    final uri = Uri.parse('$_baseUrl/search/album').replace(queryParameters: {'q': query});
    final body = await _get(uri) as Map<String, dynamic>;
    final data = (body['data'] as List?) ?? [];
    return data
        .whereType<Map>()
        .map((a) => Album.fromJson(Map<String, dynamic>.from(a)))
        .toList();
  }

  /// Full album detail, including tracklist, used on the Album Detail screen.
  Future<Album> getAlbumDetail(int albumId) async {
    final body = await _get(Uri.parse('$_baseUrl/album/$albumId')) as Map<String, dynamic>;
    return Album.fromJson(body);
  }

  /// Resolves a hand-curated (artist, album) seed — used for niche genres
  /// that Deezer has no chart/browse endpoint for — into a real Deezer
  /// [Album] with live cover art and an ID. Tries a precise field-scoped
  /// query first, then falls back to a loose text search. Returns null
  /// (rather than throwing) if nothing matches, so one missing seed doesn't
  /// take down an entire niche genre's results.
  Future<Album?> resolveSeedAlbum(String artist, String albumTitle) async {
    try {
      final precise = await searchAlbums('artist:"$artist" album:"$albumTitle"');
      if (precise.isNotEmpty) return precise.first;
      final loose = await searchAlbums('$artist $albumTitle');
      if (loose.isNotEmpty) return loose.first;
      return null;
    } catch (_) {
      return null;
    }
  }
}
