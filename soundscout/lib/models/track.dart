class Track {
  final int id;
  final String title;
  final int duration;

  Track({
    required this.id,
    required this.title,
    required this.duration,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? json['title_short'] ?? 'Untitled') as String,
      duration: json['duration'] is int ? json['duration'] as int : int.tryParse('${json['duration']}') ?? 0,
    );
  }
}
