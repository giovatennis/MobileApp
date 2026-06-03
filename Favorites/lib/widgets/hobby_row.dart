import 'package:flutter/material.dart';
import '../models/hobby_model.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class HobbyRow extends StatelessWidget {
  final HobbyModel hobby;

  const HobbyRow({
    super.key,
    required this.hobby,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          hobby.hobbyIcon,
          style: TextStyle(fontSize: 28),
        ),
        title: Text(hobby.hobbyName),
        trailing: IconButton(
          onPressed: () {
            context
                .read<FavoritesProvider>()
                .toggleHobbyFavorite(hobby.id);
          },
          icon: Icon(
            hobby.isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
          ),
        ),
      ),
    );
  }
}