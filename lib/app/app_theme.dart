import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF14243A);
  static const navyDeep = Color(0xFF0C1727);
  static const gold = Color(0xFFC6A15B);
  static const cream = Color(0xFFF7F4EC);
  static const ink = Color(0xFF202938);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
      primary: navy,
      secondary: gold,
      surface: cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(backgroundColor: cream, foregroundColor: ink, elevation: 0),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE9E3D7)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: gold.withValues(alpha: 0.18),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.dark,
      primary: const Color(0xFFE2C27F),
      secondary: gold,
      surface: navy,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: navyDeep,
      appBarTheme: const AppBarTheme(backgroundColor: navyDeep, foregroundColor: Colors.white, elevation: 0),
      cardTheme: CardThemeData(
        color: navy,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2B3B50)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: navy,
        indicatorColor: Color(0xFF39445A),
      ),
    );
  }
}
