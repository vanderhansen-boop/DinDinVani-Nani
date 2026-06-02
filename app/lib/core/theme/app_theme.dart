import 'package:flutter/material.dart';
import '../../domain/entities/family_settings.dart';

/// Motor de temas do DinDinVani&Nani
/// Gera ThemeData completo a partir de ColorSchemeType
class AppTheme {
  AppTheme._();

  static Color seedColor(ColorSchemeType scheme) {
    switch (scheme) {
      case ColorSchemeType.pink:   return const Color(0xFFE91E8C);
      case ColorSchemeType.blue:   return const Color(0xFF1565C0);
      case ColorSchemeType.green:  return const Color(0xFF2E7D32);
      case ColorSchemeType.purple: return const Color(0xFF6A1B9A);
      case ColorSchemeType.orange: return const Color(0xFFE65100);
      case ColorSchemeType.teal:   return const Color(0xFF00695C);
    }
  }

  static ThemeData light(ColorSchemeType scheme) {
    final seed = seedColor(scheme);
    return ThemeData(
      useMaterial3:  true,
      colorScheme:   ColorScheme.fromSeed(
          seedColor: seed, brightness: Brightness.light),
      fontFamily:    'Nunito',
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation:   0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData dark(ColorSchemeType scheme) {
    final seed = seedColor(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme:  ColorScheme.fromSeed(
          seedColor: seed, brightness: Brightness.dark),
      fontFamily:   'Nunito',
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation:   0,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeMode toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:  return ThemeMode.light;
      case AppThemeMode.dark:   return ThemeMode.dark;
      case AppThemeMode.system: return ThemeMode.system;
    }
  }
}