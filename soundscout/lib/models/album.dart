import 'track.dart';

/// Represents an album from the Deezer catalog. The same model is used for
/// search results, genre chart results, and the full album detail response —
/// those payloads share the core fields; [tracklist] and [releaseDate] are
/// only populated once the full detail has been fetched.
class Album {
  final int id;
  final String title;
  final String artist;
  final String coverUrl;
  final String? releaseDate;
  final int? trackCount;
  final List<Track>? tracklist;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.releaseDate,
    this.trackCount,
    this.tracklist,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    List<Track>? tracks;
    final tracksJson = json['tracks'];
    if (tracksJson is Map && tracksJson['data'] is List) {
      tracks = (tracksJson['data'] as List)
          .whereType<Map>()
          .map((t) => Track.fromJson(Map<String, dynamic>.from(t)))
          .toList();
    }

    String artistName = 'Unknown Artist';
    final artistJson = json['artist'];
    if (artistJson is Map && artistJson['name'] != null) {
      artistName = artistJson['name'].toString();
    }

    return Album(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? 'Unknown Title') as String,
      artist: artistName,
      coverUrl: (json['cover_medium'] ?? json['cover_big'] ?? json['cover'] ?? '') as String,
      releaseDate: json['release_date'] as String?,
      trackCount: json['nb_tracks'] is int ? json['nb_tracks'] as int : null,
      tracklist: tracks,
    );
  }
}
