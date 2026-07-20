import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/discover_provider.dart';
import 'providers/library_provider.dart';
import 'providers/search_provider.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const SoundScoutApp());
}

class SoundScoutApp extends StatelessWidget {
  const SoundScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DiscoverProvider()
            ..loadGenres()
            ..loadNicheGenres(),
        ),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()..loadEntries()),
      ],
      child: MaterialApp(
        title: 'SoundScout',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
