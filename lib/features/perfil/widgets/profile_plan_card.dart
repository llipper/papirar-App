import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';

class ProfilePlanCard extends StatelessWidget {
  final ProfileColors colors;
  final VoidCallback onOpenLeiSeca;

  const ProfilePlanCard({
    super.key,
    required this.colors,
    required this.onOpenLeiSeca,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onOpenLeiSeca,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.inner,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: colors.text,
                          size: 28,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 9,
                      bottom: 9,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.positive,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biblioteca atual',
                      style: GoogleFonts.quicksand(
                        color: colors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lei seca com áudio liberada para estudo e revisão.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        color: colors.muted,
                        fontSize: 12,
                        height: 1.28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      'Abrir Lei Seca',
                      style: GoogleFonts.quicksand(
                        color: colors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
