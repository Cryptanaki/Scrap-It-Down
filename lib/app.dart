
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class ScrapItDownApp extends StatelessWidget {
  const ScrapItDownApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Green palette with white text
    final primary = const Color(0xFF2E7D32); // green 700
    final accent = const Color(0xFF66BB6A); // light green

    final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
      primary: primary,
      secondary: accent,
      surface: primary,
      onPrimary: Colors.white,
      onSurface: Colors.white,
      onSecondary: Colors.white,
    );

    return MaterialApp(
      title: 'Scrap It Down',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: primary,
        appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white, elevation: 0),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: primary,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: accent, foregroundColor: Colors.white),
        textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}
