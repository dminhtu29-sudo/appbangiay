import 'package:flutter/material.dart';

/// 🎨 Bảng màu chủ đạo retro nâu - kem
class RetroTheme {
  static const Color brown = Color(0xFF8B5E3C);
  static const Color brownLight = Color(0xFFD7BFAE);
  static const Color beige = Color(0xFFFAF3E0);
  static const Color textDark = Color(0xFF4E342E);
  static const Color textLight = Color(0xFF6D4C41);

  /// Toàn bộ theme MaterialApp
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: beige,
      primaryColor: brown,
      appBarTheme: const AppBarTheme(
        backgroundColor: brown,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textDark, fontFamily: 'Poppins'),
        titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: brownLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: brown, width: 2),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: brown,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
