import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:papirar/features/splash/splash_screen.dart';

class SplashBookShowcase extends StatelessWidget {
  final SplashColors colors;

  const SplashBookShowcase({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Center(
        child: Transform.rotate(
          angle: -0.075,
          child: Container(
            width: 230,
            height: 328,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.phone,
              borderRadius: BorderRadius.circular(42),
              border: Border.all(color: colors.phoneBorder, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              decoration: BoxDecoration(
                color: colors.phoneScreen,
                borderRadius: BorderRadius.circular(34),
              ),
              child: Column(
                children: [
                  const _PhoneStatusBar(),
                  const SizedBox(height: 30),
                  const _BookCards(),
                  const SizedBox(height: 30),
                  Text(
                    'BIBLIOTECA GUIADA',
                    style: GoogleFonts.quicksand(
                      color: colors.muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Código Penal\nem áudio',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      color: colors.text,
                      fontSize: 22,
                      height: 1.02,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AudioPreview(colors: colors),
                  const Spacer(),
                  Container(
                    width: 72,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.text.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '23:52',
          style: GoogleFonts.quicksand(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Container(
          width: 62,
          height: 17,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const Spacer(),
        const Icon(Icons.signal_cellular_alt_rounded, size: 10),
        const SizedBox(width: 3),
        const Icon(Icons.battery_full_rounded, size: 12),
      ],
    );
  }
}

class _BookCards extends StatelessWidget {
  const _BookCards();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 28,
            child: _BookCard(
              title: 'CF',
              color: Color(0xFF9BBFC4),
              rotation: -0.12,
            ),
          ),
          _BookCard(
            title: 'CP',
            color: Color(0xFFC92535),
            rotation: 0,
            foreground: Colors.white,
          ),
          Positioned(
            right: 28,
            child: _BookCard(
              title: 'CPP',
              color: Color(0xFFD6A149),
              rotation: 0.12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color foreground;
  final double rotation;

  const _BookCard({
    required this.title,
    required this.color,
    required this.rotation,
    this.foreground = const Color(0xFF111111),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 58,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.quicksand(
              color: foreground,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioPreview extends StatelessWidget {
  final SplashColors colors;

  const _AudioPreview({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.fromLTRB(7, 6, 10, 6),
      decoration: BoxDecoration(
        color: colors.audio,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.play, size: 15, color: Colors.black),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Row(
              children: [
                _WaveBar(height: 8),
                _WaveBar(height: 16),
                _WaveBar(height: 11),
                _WaveBar(height: 20),
                _WaveBar(height: 13),
                _WaveBar(height: 17),
                _WaveBar(height: 9),
              ],
            ),
          ),
          Text(
            'Art. 7º',
            style: GoogleFonts.quicksand(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final double height;

  const _WaveBar({required this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
