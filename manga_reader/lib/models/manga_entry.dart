class MangaEntry {
  final int? id;
  final String title;
  final String volume;
  final String status; // 'Reading', 'Completed', 'Wishlist'
  final String notes;
  final String scannedText; // raw ML Kit output, saved for reference
  final DateTime createdAt;

  MangaEntry({
    this.id,
    required this.title,
    required this.volume,
    required this.status,
    required this.notes,
    required this.scannedText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'volume': volume,
      'status': status,
      'notes': notes,
      'scannedText': scannedText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MangaEntry.fromMap(Map<String, dynamic> map) {
    return MangaEntry(
      id: map['id'],
      title: map['title'] ?? '',
      volume: map['volume'] ?? '',
      status: map['status'] ?? 'Reading',
      notes: map['notes'] ?? '',
      scannedText: map['scannedText'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  MangaEntry copyWith({
    int? id,
    String? title,
    String? volume,
    String? status,
    String? notes,
    String? scannedText,
    DateTime? createdAt,
  }) {
    return MangaEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      volume: volume ?? this.volume,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      scannedText: scannedText ?? this.scannedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
