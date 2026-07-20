import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Loads the bundled local dataset of genre descriptions
/// (assets/genre_descriptions.json). This is intentionally NOT fetched from
/// any API — Deezer's genre objects only have a name and picture, no text
/// description, so these are curated blurbs shipped with the app.
///
/// Genre names returned by the Deezer API can vary slightly by catalog/locale,
/// so any genre without a matching entry falls back to a generic description
/// rather than crashing or showing a blank screen.
class GenreDescriptionService {
  Map<String, String>? _cache;

  Future<Map<String, String>> loadDescriptions() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/genre_descriptions.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    _cache = decoded.map((key, value) => MapEntry(key, value.toString()));
    return _cache!;
  }

  String describe(Map<String, String> descriptions, String genreName) {
    return descriptions[genreName] ??
        'Explore top albums in $genreName and start building your ratings for this genre.';
  }
}
