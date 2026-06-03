import 'package:flutter/material.dart';
import 'screens/content_view.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';


void main() {
  runApp(const FavoritesApp());
}

class FavoritesApp extends StatelessWidget {
  const FavoritesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black
            ),
            themeMode: favoritesProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: ContentView(),
          );
        })
      );
    
  }
}