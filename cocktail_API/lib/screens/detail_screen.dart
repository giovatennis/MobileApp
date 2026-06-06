import 'package:flutter/material.dart';
import '../models/cocktail_model.dart';
import '../services/cocktail_service.dart';

class DetailScreen extends StatefulWidget {
  final String cocktailId;

  const DetailScreen({super.key, required this.cocktailId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CocktailService _service = CocktailService();
  CocktailModel? _cocktail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getCocktailById(widget.cocktailId);
      setState(() {
        _cocktail = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load cocktail details. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _cocktail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Cocktail not found.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final cocktail = _cocktail!;

    return CustomScrollView(
      slivers: [
        // Collapsible image header
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              cocktail.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
            background: cocktail.thumbnailUrl != null
                ? Image.network(
                    cocktail.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                  )
                : Container(color: Colors.grey[300]),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (cocktail.alcoholic != null)
                      _Badge(label: cocktail.alcoholic!),
                    if (cocktail.category != null)
                      _Badge(label: cocktail.category!),
                    if (cocktail.glass != null)
                      _Badge(label: cocktail.glass!),
                  ],
                ),

                const SizedBox(height: 24),

                // Ingredients
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(cocktail.ingredients.length, (i) {
                  final ingredient = cocktail.ingredients[i];
                  final measure = cocktail.measures[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style.copyWith(
                                    fontSize: 15,
                                    color: Colors.red,
                                    decoration: TextDecoration.none,
                                  ),
                              children: [
                                if (measure.isNotEmpty)
                                  TextSpan(
                                    text: '$measure ',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                TextSpan(text: ingredient),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Instructions
                if (cocktail.instructions != null) ...[
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    cocktail.instructions!,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
