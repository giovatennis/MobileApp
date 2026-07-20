/// A hand-picked album to seed a niche genre's discovery list. Only the
/// artist/album name is stored here — real cover art, IDs, and tracklist
/// are resolved live against Deezer's search endpoint, never hard-coded.
class AlbumSeed {
  final String artist;
  final String album;

  AlbumSeed({required this.artist, required this.album});

  factory AlbumSeed.fromJson(Map<String, dynamic> json) {
    return AlbumSeed(
      artist: (json['artist'] ?? '') as String,
      album: (json['album'] ?? '') as String,
    );
  }
}

/// A curated niche/deep-cut genre (e.g. Shoegaze, Neo-Psychedelia). Deezer's
/// own /genre endpoint only exposes ~20-30 broad top-level categories, with
/// no way to browse anything this specific — this dataset (bundled as
/// assets/niche_genres.json) fills that gap.
class NicheGenre {
  final String name;
  final String description;
  final List<AlbumSeed> seeds;

  NicheGenre({
    required this.name,
    required this.description,
    required this.seeds,
  });

  factory NicheGenre.fromJson(Map<String, dynamic> json) {
    final seedsJson = (json['seeds'] as List?) ?? [];
    return NicheGenre(
      name: (json['name'] ?? 'Unknown') as String,
      description: (json['description'] ?? '') as String,
      seeds: seedsJson
          .whereType<Map>()
          .map((s) => AlbumSeed.fromJson(Map<String, dynamic>.from(s)))
          .toList(),
    );
  }
}
