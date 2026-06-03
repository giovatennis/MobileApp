import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';

class FavoritesProvider extends ChangeNotifier {

  bool isDarkMode = false;

  final cities = sampleCities;
  final hobbies = sampleHobbies;
  final books = sampleBooks;

  FavoritesProvider() {
    loadFavorites();
  }

  // --- Cities ---

  void toggleCityFavorite(int cityId) {
    final city = cities.firstWhere((city) => city.id == cityId);
    city.isFavorite = !city.isFavorite;
    saveFavorites();
    notifyListeners();
  }

  // --- Hobbies ---

  void toggleHobbyFavorite(int hobbyId) {
    final hobby = hobbies.firstWhere((hobby) => hobby.id == hobbyId);
    hobby.isFavorite = !hobby.isFavorite;
    saveFavorites();
    notifyListeners();
  }

  // --- Books ---

  void toggleBookFavorite(int bookId) {
    final book = books.firstWhere((book) => book.id == bookId);
    book.isFavorite = !book.isFavorite;
    saveFavorites();
    notifyListeners();
  }

  // --- Dark Mode ---

  void toggleDarkMode(bool value) {
    isDarkMode = value;
    saveFavorites();
    notifyListeners();
  }

  // --- Clear All Favorites ---

  void clearAllFavorites() {
    for (final city in cities)
    { 
      city.isFavorite = false;
    }
    for (final hobby in hobbies) {
      hobby.isFavorite = false;
    }
    for (final book in books) {
      book.isFavorite = false;
    }
    saveFavorites();
    notifyListeners();
  }

  // --- Persistence ---

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'favoriteCities',
      cities.where((c) => c.isFavorite).map((c) => c.id.toString()).toList(),
    );
    await prefs.setStringList(
      'favoriteHobbies',
      hobbies.where((h) => h.isFavorite).map((h) => h.id.toString()).toList(),
    );
    await prefs.setStringList(
      'favoriteBooks',
      books.where((b) => b.isFavorite).map((b) => b.id.toString()).toList(),
    );
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final favCities = prefs.getStringList('favoriteCities') ?? [];
    for (final city in cities) {
      city.isFavorite = favCities.contains(city.id.toString());
    }

    final favHobbies = prefs.getStringList('favoriteHobbies') ?? [];
    for (final hobby in hobbies) {
      hobby.isFavorite = favHobbies.contains(hobby.id.toString());
    }

    final favBooks = prefs.getStringList('favoriteBooks') ?? [];
    for (final book in books) {
      book.isFavorite = favBooks.contains(book.id.toString());
    }

    isDarkMode = prefs.getBool('isDarkMode') ?? false;

    notifyListeners();
  }
}
