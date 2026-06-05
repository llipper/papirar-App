import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeiReadingStyles {
  final TextStyle body;
  final TextStyle dropCap;
  final TextStyle heading;
  final TextStyle rubrica;
  final Color textColor;

  const LeiReadingStyles({
    required this.body,
    required this.dropCap,
    required this.heading,
    required this.rubrica,
    required this.textColor,
  });

  factory LeiReadingStyles.fromTheme({
    required Color textColor,
    required double textSize,
  }) {
    return LeiReadingStyles(
      textColor: textColor,
      body: GoogleFonts.lora(
        fontSize: textSize,
        fontWeight: FontWeight.w400,
        color: textColor.withValues(alpha: 0.85),
        height: 1.65,
      ),
      dropCap: GoogleFonts.playfairDisplay(
        fontSize: textSize * 3.5,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.0,
      ),
      heading: GoogleFonts.playfairDisplay(
        fontSize: textSize * 1.15,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      rubrica: GoogleFonts.lora(
        fontSize: textSize * 0.94,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.35,
      ),
    );
  }
}
