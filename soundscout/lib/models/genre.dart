class Genre {
  final int id;
  final String name;
  final String pictureUrl;

  Genre({
    required this.id,
    required this.name,
    required this.pictureUrl,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? 'Unknown Genre') as String,
      pictureUrl: (json['picture_medium'] ?? json['picture'] ?? json['picture_big'] ?? '') as String,
    );
  }
}
