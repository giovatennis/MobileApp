import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cocktail_model.dart';

class CocktailService {
  static const String _baseUrl =
      'https://www.thecocktaildb.com/api/json/v1/1';

  /// Search cocktails by name. Defaults to 'a' to return a broad initial list.
  Future<List<CocktailModel>> searchCocktails(String query) async {
    final searchTerm = query.trim().isEmpty ? 'a' : query.trim();
    final uri = Uri.parse('$_baseUrl/search.php?s=$searchTerm');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load cocktails (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final drinks = data['drinks'];

    if (drinks == null) return [];

    return (drinks as List)
        .map((json) => CocktailModel.fromJson(json))
        .toList();
  }

  /// Look up full cocktail details by ID.
  Future<CocktailModel?> getCocktailById(String id) async {
    final uri = Uri.parse('$_baseUrl/lookup.php?i=$id');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load cocktail detail (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final drinks = data['drinks'];

    if (drinks == null || (drinks as List).isEmpty) return null;

    return CocktailModel.fromJson(drinks[0]);
  }
}
