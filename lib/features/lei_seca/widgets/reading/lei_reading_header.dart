import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeiReadingHeader extends StatelessWidget {
  final String sigla;
  final String titulo;
  final Color textColor;
  final VoidCallback onBack;

  const LeiReadingHeader({
    super.key,
    required this.sigla,
    required this.titulo,
    required this.textColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
              onPressed: onBack,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          sigla,
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}