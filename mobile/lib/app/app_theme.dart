import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      error: AppColors.expense,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.background,

      fontFamily: 'Roboto',
      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: AppColors.textPrimary,
        ),

        headlineSmall: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),

        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),

        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),

        bodySmall: TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      // Navigation
      navigationBarTheme: NavigationBarThemeData(
        height: 76,

        elevation: 0,

        backgroundColor: AppColors.surface,

        surfaceTintColor: Colors.transparent,

        indicatorColor: AppColors.primaryLight,

        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            );
          }

          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),

        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 23);
          }

          return const IconThemeData(color: AppColors.textSecondary, size: 22);
        }),
      ),
      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),

          padding: const EdgeInsets.symmetric(horizontal: 22),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.surfaceSoft,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),

          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),

          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
