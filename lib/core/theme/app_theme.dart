import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Strict Base Colors (ONLY black and white - no accent colors)
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: pureWhite,
      scaffoldBackgroundColor: pureBlack,
      colorScheme: const ColorScheme.dark(
        primary: pureWhite,
        secondary: pureWhite,
        surface: pureBlack,
        onPrimary: pureBlack,
        onSecondary: pureBlack,
        onSurface: pureWhite,
      ),
      textTheme: GoogleFonts.quicksandTextTheme(
        ThemeData.dark().textTheme.copyWith(
          titleLarge: const TextStyle(
            color: pureWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyLarge: const TextStyle(color: pureWhite, fontSize: 16),
          bodyMedium: const TextStyle(color: pureWhite, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureBlack,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: pureWhite),
        titleTextStyle: TextStyle(
          color: pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardThemeData(
        color: pureBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: pureWhite,
            width: 1,
          ), // Minimalist border instead of elevation
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(color: pureWhite, thickness: 1),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: pureBlack,
      scaffoldBackgroundColor: pureWhite,
      colorScheme: const ColorScheme.light(
        primary: pureBlack,
        secondary: pureBlack,
        surface: pureWhite,
        onPrimary: pureWhite,
        onSecondary: pureWhite,
        onSurface: pureBlack,
      ),
      textTheme: GoogleFonts.quicksandTextTheme(
        ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(
            color: pureBlack,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyLarge: const TextStyle(color: pureBlack, fontSize: 16),
          bodyMedium: const TextStyle(color: pureBlack, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: pureBlack),
        titleTextStyle: TextStyle(
          color: pureBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardThemeData(
        color: pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: pureBlack, width: 1), // Minimalist border
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dividerTheme: const DividerThemeData(color: pureBlack, thickness: 1),
    );
  }
}
