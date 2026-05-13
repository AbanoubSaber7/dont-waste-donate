import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brown and Beige Theme Colors
  static const Color brown = Color(0xFF8B4513);         // Brown Base (like in logo)
  static const Color brownDark = Color(0xFF654321);    // Darker brown for gradients
  static const Color brownLight = Color(0xFFD2B48C);   // Beige for backgrounds
  
  static const Color textBlack = Color(0xFF2D3142);     // Soft dark for text
  static const Color textGrey = Color(0xFF9094A6);      // Muted grey for subtexts
  static const Color surfaceBeige = Color(0xFFF5F5DC);  // Beige surface color

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceBeige,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brown,
        primary: brown,
        secondary: brownDark,
        surface: surfaceBeige,
        onSurface: textBlack,
        brightness: Brightness.light,
      ),
      
      // Typography
      textTheme: GoogleFonts.cairoTextTheme().apply(
        bodyColor: textBlack,
        displayColor: textBlack,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textBlack),
        titleTextStyle: TextStyle(
          color: textBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: brown, width: 2),
        ),
        hintStyle: const TextStyle(color: textGrey, fontSize: 14),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0, // Flat design for modern look
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Cairo'),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brown,
          side: const BorderSide(color: brown, width: 2),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Cairo'),
        ),
      ),
    );
  }
}