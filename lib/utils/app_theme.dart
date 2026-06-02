import 'package:flutter/material.dart';

class AppColors {
  static const teal = Color(0xFF0F6E56); // dark green
  static const mint = Color(0xFFE8F5E9); // light green
  static const blush = Color(0xFFE8F5E9); // light green
  static const rose = Color(0xFFDDB2A8);
  static const sand = Color(0xFFD6CBBF);
  static const cream = Color(0xFFF0EEEA);
  static const darkText = Color(0xFF3A3A38);
  static const mutedText = Color(0xFF7A7A78);
  static const white = Color(0xFFFFFFFF);
  static const tealDark = Color(0xFF2E5249);
  static const roseDark = Color(0xFF5A3A35);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'DM Sans',
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: const ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.rose,
      surface: AppColors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sand, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.sand, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}
