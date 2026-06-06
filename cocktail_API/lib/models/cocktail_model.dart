class CocktailModel {
  final String id;
  final String name;
  final String? category;
  final String? alcoholic;
  final String? glass;
  final String? instructions;
  final String? thumbnailUrl;
  final List<String> ingredients;
  final List<String> measures;

  CocktailModel({
    required this.id,
    required this.name,
    this.category,
    this.alcoholic,
    this.glass,
    this.instructions,
    this.thumbnailUrl,
    required this.ingredients,
    required this.measures,
  });

  factory CocktailModel.fromJson(Map<String, dynamic> json) {
    // Ingredients and measures are stored as strIngredient1..15, strMeasure1..15
    final ingredients = <String>[];
    final measures = <String>[];

    for (int i = 1; i <= 15; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return CocktailModel(
      id: json['idDrink'] ?? '',
      name: json['strDrink'] ?? 'Unknown',
      category: json['strCategory'],
      alcoholic: json['strAlcoholic'],
      glass: json['strGlass'],
      instructions: json['strInstructions'],
      thumbnailUrl: json['strDrinkThumb'],
      ingredients: ingredients,
      measures: measures,
    );
  }
}
