import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🔥 Firebase initialized successfully");

  runApp(const CocktailApp());
}

class CocktailApp extends StatelessWidget {
  const CocktailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cocktails',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D7377),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A2342),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}