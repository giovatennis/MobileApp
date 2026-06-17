import 'package:flutter/material.dart';
import '../models/cocktail_model.dart';
import '../services/cocktail_service.dart';
import '../widgets/cocktail_card.dart';
import 'detail_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CocktailService _service = CocktailService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<CocktailModel> _cocktails = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCocktails('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log Out'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );

  if (shouldLogout == true) {
    await _authService.signOut();
    // AuthGate's stream listener handles navigation back to LoginScreen.
  }
}

  Future<void> _loadCocktails(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _service.searchCocktails(query);
      setState(() {
        _cocktails = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String value) {
    _loadCocktails(value);
  }

  void _clearSearch() {
    _searchController.clear();
    _loadCocktails('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
        Container(
          width: double.infinity,
          color: const Color(0xFF0A2342),
          padding: const EdgeInsets.fromLTRB(20, 52, 12, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Cocktails',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search your favorite cocktail and tap to discover the recipe',
                      style: TextStyle(
                        color: Color(0xFF8BBFD4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Log out',
              ),
            ],
          ),
        ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search cocktails...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
              },
            ),
          ),

          // Results count
          if (!_isLoading && _errorMessage == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_cocktails.length} result${_cocktails.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // Content area
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadCocktails(_searchController.text),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cocktails.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_bar_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No cocktails found for "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: _cocktails.length,
      itemBuilder: (context, index) {
        final cocktail = _cocktails[index];
        return CocktailCard(
          cocktail: cocktail,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(cocktailId: cocktail.id),
              ),
            );
          },
        );
      },
    );
  }
}
