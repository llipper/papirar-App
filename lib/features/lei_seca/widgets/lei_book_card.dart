import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/lei_seca/models/lei_model.dart';

class LeiBookCard extends StatelessWidget {
  final LeiModel lei;
  final VoidCallback onTap;

  const LeiBookCard({
    super.key,
    required this.lei,
    required this.onTap,
  });

  static const _coverColors = [
    Color(0xFF4169E1),
    Color(0xFF19B943),
    Color(0xFF5C0E8A),
    Color(0xFFB8325A),
    Color(0xFF0F8B8D),
    Color(0xFFD98C21),
    Color(0xFF263A8B),
    Color(0xFF6A8D1A),
    Color(0xFF8C2639),
  ];

  @override
  Widget build(BuildContext context) {
    final numericId = int.tryParse(lei.id);
    final colorIndex = numericId == null
        ? lei.id.hashCode.abs() % _coverColors.length
        : (numericId - 1).abs() % _coverColors.length;
    final bgColor = _coverColors[colorIndex];
    final isDarkBackground = bgColor.computeLuminance() < 0.5;
    final textColor = isDarkBackground ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Text Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lei.categoria.toUpperCase(),
                    style: GoogleFonts.quicksand(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lei.titulo,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.1,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      lei.sigla,
                      style: GoogleFonts.quicksand(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
