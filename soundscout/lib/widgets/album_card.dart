import 'package:flutter/material.dart';

import '../models/album.dart';
import 'star_rating.dart';

/// A reusable list row for an album — used on Discover, Search, and Library
/// screens. Shows the user's own rating as a badge when the album has
/// already been saved.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.userRating,
  });

  final Album album;
  final VoidCallback onTap;
  final int? userRating;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: album.coverUrl.isNotEmpty
              ? Image.network(
                  album.coverUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        title: Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(album.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: userRating != null
            ? StarRating(rating: userRating!, size: 16)
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 56,
        height: 56,
        color: Colors.grey.shade300,
        child: const Icon(Icons.album, color: Colors.grey),
      );
}
