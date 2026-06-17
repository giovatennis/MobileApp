import 'package:flutter/material.dart';
import '../models/cocktail_model.dart';

class CocktailCard extends StatelessWidget {
  final CocktailModel cocktail;
  final VoidCallback onTap;

  const CocktailCard({
    super.key,
    required this.cocktail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed-height thumbnail
            SizedBox(
              height: 80,
              width: double.infinity,
              child: cocktail.thumbnailUrl != null
                  ? Image.network(
                      cocktail.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderImage(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xFFEEF2F5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0D7377),
                            ),
                          ),
                        );
                      },
                    )
                  : _PlaceholderImage(),
            ),

            // Name + category
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cocktail.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Color(0xFF0A2342),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cocktail.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      cocktail.category!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF0D7377),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEF2F5),
      child: const Center(
        child: Icon(Icons.local_bar_outlined, size: 32, color: Color(0xFF0D7377)),
      ),
    );
  }
}
