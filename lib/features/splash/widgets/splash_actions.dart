import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/splash/splash_screen.dart';

class SplashActions extends StatelessWidget {
  final SplashColors colors;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;
  final String primaryLabel;
  final String secondaryLabel;

  const SplashActions({
    super.key,
    required this.colors,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    this.primaryLabel = 'Começar pela Lei Seca',
    this.secondaryLabel = 'Ir para o início',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: onPrimaryTap,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.primaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              primaryLabel,
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: onSecondaryTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.secondary,
              foregroundColor: colors.secondaryText,
              side: BorderSide(
                color: colors.secondaryText.withValues(alpha: 0.08),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              secondaryLabel,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
