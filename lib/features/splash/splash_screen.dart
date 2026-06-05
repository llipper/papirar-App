import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/splash/widgets/splash_actions.dart';
import 'package:papirar/features/splash/widgets/splash_book_showcase.dart';
import 'package:papirar/features/splash/widgets/splash_feature_strip.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = SplashColors.fromBrightness(isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _SplashBackground(colors: colors)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 44,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        SplashBookShowcase(colors: colors),
                        const SizedBox(height: 34),
                        Text(
                          'papirar',
                          style: GoogleFonts.quicksand(
                            color: colors.muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Lei seca com áudio,\nsem perder o foco.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: colors.text,
                            fontSize: 28,
                            height: 1.08,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Leia seus códigos, acompanhe artigos importantes e ouça explicações quando precisar revisar.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            color: colors.muted,
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SplashFeatureStrip(colors: colors),
                        const SizedBox(height: 28),
                        SplashActions(
                          colors: colors,
                          primaryLabel: 'Entrar no Papirar',
                          secondaryLabel: 'Criar conta',
                          onPrimaryTap: () => context.go('/login'),
                          onSecondaryTap: () => context.go('/cadastro'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  final SplashColors colors;

  const _SplashBackground({required this.colors});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.background, colors.lowerBackground],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -80,
            child: _SoftShape(color: colors.shape),
          ),
          Positioned(
            top: 92,
            right: -120,
            child: _SoftShape(color: colors.shape),
          ),
          Positioned(
            bottom: 120,
            left: -130,
            child: _SoftShape(color: colors.shape.withValues(alpha: 0.46)),
          ),
        ],
      ),
    );
  }
}

class _SoftShape extends StatelessWidget {
  final Color color;

  const _SoftShape({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(90),
      ),
    );
  }
}

class SplashColors {
  final Color background;
  final Color lowerBackground;
  final Color shape;
  final Color phone;
  final Color phoneBorder;
  final Color phoneScreen;
  final Color text;
  final Color muted;
  final Color surface;
  final Color primary;
  final Color primaryText;
  final Color secondary;
  final Color secondaryText;
  final Color audio;

  const SplashColors({
    required this.background,
    required this.lowerBackground,
    required this.shape,
    required this.phone,
    required this.phoneBorder,
    required this.phoneScreen,
    required this.text,
    required this.muted,
    required this.surface,
    required this.primary,
    required this.primaryText,
    required this.secondary,
    required this.secondaryText,
    required this.audio,
  });

  factory SplashColors.fromBrightness(bool isDark) {
    if (isDark) {
      return const SplashColors(
        background: Color(0xFF0B0B0C),
        lowerBackground: Color(0xFF151516),
        shape: Color(0xFF222224),
        phone: Color(0xFFEDEDED),
        phoneBorder: Color(0xFF0B0B0C),
        phoneScreen: Color(0xFFF6F6F4),
        text: Color(0xFFF3F3F1),
        muted: Color(0xFF9A9A9A),
        surface: Color(0xFF1C1C1D),
        primary: Color(0xFFF2F2F0),
        primaryText: Color(0xFF0B0B0C),
        secondary: Color(0xFF242426),
        secondaryText: Color(0xFFF2F2F0),
        audio: Color(0xFF141414),
      );
    }

    return const SplashColors(
      background: Color(0xFFE7E7E4),
      lowerBackground: Color(0xFFF2F2EF),
      shape: Color(0xFFD5D5D1),
      phone: Color(0xFF0E0E10),
      phoneBorder: Color(0xFF050505),
      phoneScreen: Color(0xFFFAFAF8),
      text: Color(0xFF111111),
      muted: Color(0xFF8A8A86),
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF111111),
      primaryText: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFFFFF),
      secondaryText: Color(0xFF111111),
      audio: Color(0xFF111111),
    );
  }
}
