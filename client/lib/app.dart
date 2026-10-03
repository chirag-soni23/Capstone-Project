import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF8F4F2),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFB86F7A),
      primary: const Color(0xFF9F5965),
      secondary: const Color(0xFFD8CBB8),
      tertiary: const Color(0xFF8FA487),
      surface: const Color(0xFFF5ECED),
    ),

    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(
        color: const Color(0xFF292426),
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: const Color(0xFF292426),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF292426),
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF292426),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF292426),
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF756C70),
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F4F2),
      elevation: 0,
      foregroundColor: Color(0xFF292426),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFFFFFBFA),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1E9E8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF9F5965),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9F5965),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFBFA),
      selectedItemColor: Color(0xFF9F5965),
      unselectedItemColor: Color(0xFF9B9295),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}