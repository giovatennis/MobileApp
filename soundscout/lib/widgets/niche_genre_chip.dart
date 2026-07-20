import 'package:flutter/material.dart';

import '../models/niche_genre.dart';

/// A tappable tile for a niche/deep-cut genre. Unlike [GenreChip] these
/// have no cover photo — Deezer doesn't expose artwork for a genre concept
/// it doesn't itself track — so this uses a deterministic color treatment
/// (derived from the genre's name) instead.
class NicheGenreChip extends StatelessWidget {
  const NicheGenreChip({super.key, required this.genre, required this.onTap});

  final NicheGenre genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Colors.primaries[genre.name.hashCode.abs() % Colors.primaries.length];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.shade700, palette.shade900],
          ),
        ),
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Text(
          genre.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
