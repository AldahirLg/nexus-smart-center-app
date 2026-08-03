import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0d47a1);
  static const secondary = Color(0xFF2196f3);
  static const background = Colors.white;
  static const error = Color(0xFFD63031);
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.primary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.primary),
      labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: AppColors.primary),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    ),
  );
}
