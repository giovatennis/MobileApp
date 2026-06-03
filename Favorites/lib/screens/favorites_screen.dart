import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/city_card.dart';
import '../widgets/hobby_row.dart';
import '../widgets/book_row.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _confirmClearAll(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear All Favorites"),
        content: Text(
            "Are you sure you want to remove all favorites? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              provider.clearAllFavorites();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Clear All"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);

    final favCities = provider.cities.where((c) => c.isFavorite).toList();
    final favHobbies = provider.hobbies.where((h) => h.isFavorite).toList();
    final favBooks = provider.books.where((b) => b.isFavorite).toList();

    final hasAnyFavorite =
        favCities.isNotEmpty || favHobbies.isNotEmpty || favBooks.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Favorites",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasAnyFavorite)
                    TextButton.icon(
                      onPressed: () => _confirmClearAll(context, provider),
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(
                        "Clear All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16),

              if (!hasAnyFavorite)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          "No favorites yet",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      // --- Cities ---
                      if (favCities.isNotEmpty) ...[
                        _SectionHeader(title: "Cities"),
                        ...favCities.map((city) => CityCard(city: city)),
                        SizedBox(height: 8),
                      ],

                      // --- Hobbies ---
                      if (favHobbies.isNotEmpty) ...[
                        _SectionHeader(title: "Hobbies"),
                        ...favHobbies.map((hobby) => HobbyRow(hobby: hobby)),
                        SizedBox(height: 8),
                      ],

                      // --- Books ---
                      if (favBooks.isNotEmpty) ...[
                        _SectionHeader(title: "Books"),
                        ...favBooks.map((book) => BookRow(book: book)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
