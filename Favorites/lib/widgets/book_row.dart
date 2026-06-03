import 'package:flutter/material.dart';
import '../models/book_model.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class BookRow extends StatelessWidget {
  final BookModel book;

  const BookRow({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.menu_book_rounded,
          size: 28,
        ),
        title: Text(book.bookTitle),
        subtitle: Text(book.bookAuthor),
        trailing: IconButton(
          onPressed: () {
            context.read<FavoritesProvider>().toggleBookFavorite(book.id);
          },
          icon: Icon(
            book.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: book.isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}
