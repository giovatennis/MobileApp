import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/niche_genre.dart';

/// Loads the curated list of niche/deep-cut genres from
/// assets/niche_genres.json. This is a hand-written dataset, not something
/// pulled from Deezer — Deezer's /genre endpoint only covers broad
/// categories, so this is what makes something like "shoegaze" or
/// "neo-psychedelia" discoverable in the app at all. The albums themselves
/// are still resolved live from Deezer (see DeezerApiService.resolveSeedAlbum),
/// so cover art and IDs are never stale.
class NicheGenreService {
  List<NicheGenre>? _cache;

  Future<List<NicheGenre>> loadNicheGenres() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/niche_genres.json');
    final decoded = json.decode(raw) as List<dynamic>;
    _cache = decoded
        .whereType<Map>()
        .map((g) => NicheGenre.fromJson(Map<String, dynamic>.from(g)))
        .toList();
    return _cache!;
  }
}
