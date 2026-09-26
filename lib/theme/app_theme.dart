import 'package:flutter/material.dart';

class TypeColors {
  static const Map<String, Color> _colors = {
    'normal': Color(0xFFAAA67F),
    'fighting': Color(0xFFC12239),
    'flying': Color(0xFFA891EC),
    'poison': Color(0xFFA43E9E),
    'ground': Color(0xFFDEC16B),
    'rock': Color(0xFFB69E31),
    'bug': Color(0xFFA7B723),
    'ghost': Color(0xFF70559B),
    'steel': Color(0xFFB7B9D0),
    'fire': Color(0xFFF57D31),
    'water': Color(0xFF6493EB),
    'grass': Color(0xFF74CB48),
    'electric': Color(0xFFF9CF30),
    'psychic': Color(0xFFFB5584),
    'ice': Color(0xFF9AD6DF),
    'dragon': Color(0xFF7037FF),
    'dark': Color(0xFF75574C),
    'fairy': Color(0xFFE69EAC),
  };

  static const List<String> allTypes = [
    'normal',
    'fighting',
    'flying',
    'poison',
    'ground',
    'rock',
    'bug',
    'ghost',
    'steel',
    'fire',
    'water',
    'grass',
    'electric',
    'psychic',
    'ice',
    'dragon',
    'dark',
    'fairy',
  ];

  static Color of(String type) =>
      _colors[type.toLowerCase()] ?? _colors['normal']!;

  static Color surface(String type) =>
      Color.lerp(of(type), Colors.white, 0.72) ?? of(type);
}

class AppTheme {
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF1D1D1D);
  static const textSecondary = Color(0xFF747476);
  static const accent = Color(0xFF173EA5);
  static const danger = Color(0xFFE73B3B);
  static const heart = Color(0xFFE23B4D);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}
