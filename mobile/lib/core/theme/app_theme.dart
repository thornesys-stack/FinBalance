import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF3157E8);
  static const background = Color(0xFFF5F7FC);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF7D8799);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      fontFamily: 'sans',
    );
  }
}
