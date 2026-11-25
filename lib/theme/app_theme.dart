import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xFF111312);
  static const card = Color(0xFF1D211F);
  static const red = Color(0xFFD3F36A); // Acento de marca (nombre conservado por compatibilidad).
  static const darkRed = Color(0xFF718B2D);
  static const muted = Color(0xFFA2AAA3);
  static const line = Color(0xFF343A35);
}

String cop(double value) {
  final digits = value.toStringAsFixed(0);
  final formatted = digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '\$ $formatted';
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: const ColorScheme.dark(primary: AppColors.red, onPrimary: AppColors.black, secondary: AppColors.red, surface: AppColors.card),
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.black, foregroundColor: Colors.white, elevation: 0, centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.red)),
    ),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), textStyle: const TextStyle(fontWeight: FontWeight.w800))),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: AppColors.red, foregroundColor: AppColors.black),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: AppColors.card, indicatorColor: AppColors.darkRed),
  );
}
