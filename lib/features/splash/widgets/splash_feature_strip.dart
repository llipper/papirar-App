import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:papirar/features/splash/splash_screen.dart';

class SplashFeatureStrip extends StatelessWidget {
  final SplashColors colors;

  const SplashFeatureStrip({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.text.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FeatureItem(icon: Iconsax.book_1, label: 'Códigos', colors: colors),
          _Divider(colors: colors),
          _FeatureItem(
            icon: Iconsax.volume_high,
            label: 'Áudio',
            colors: colors,
          ),
          _Divider(colors: colors),
          _FeatureItem(
            icon: Iconsax.document_text,
            label: 'Artigos',
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final SplashColors colors;

  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colors.text, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.quicksand(
            color: colors.text.withValues(alpha: 0.76),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final SplashColors colors;

  const _Divider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: colors.text.withValues(alpha: 0.08),
    );
  }
}
