/// A user-rated album saved in the local library. This is the record that
/// actually lives in SQLite — it snapshots enough album info to render list
/// items without another network call, plus the user's own rating/review.
class LibraryEntry {
  final int? id;
  final int albumId;
  final String title;
  final String artist;
  final String coverUrl;
  final String genre;
  final int rating;
  final String review;
  final DateTime dateAdded;

  LibraryEntry({
    this.id,
    required this.albumId,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.genre,
    required this.rating,
    required this.review,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'albumId': albumId,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'genre': genre,
      'rating': rating,
      'review': review,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory LibraryEntry.fromMap(Map<String, dynamic> map) {
    return LibraryEntry(
      id: map['id'] as int?,
      albumId: map['albumId'] as int,
      title: map['title'] as String,
      artist: map['artist'] as String,
      coverUrl: map['coverUrl'] as String,
      genre: map['genre'] as String,
      rating: map['rating'] as int,
      review: (map['review'] ?? '') as String,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
    );
  }
}
