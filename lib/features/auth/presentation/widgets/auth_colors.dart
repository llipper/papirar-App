import 'package:flutter/material.dart';

class AuthColors {
  final Color background;
  final Color backgroundShape;
  final Color surface;
  final Color text;
  final Color muted;
  final Color border;
  final Color primary;
  final Color primaryText;
  final Color secondary;

  const AuthColors({
    required this.background,
    required this.backgroundShape,
    required this.surface,
    required this.text,
    required this.muted,
    required this.border,
    required this.primary,
    required this.primaryText,
    required this.secondary,
  });

  factory AuthColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AuthColors(
        background: Color(0xFF070707),
        backgroundShape: Color(0xFF171717),
        surface: Color(0xFF101010),
        text: Color(0xFFF7F7F5),
        muted: Color(0xFF9B9B9B),
        border: Color(0xFF282828),
        primary: Color(0xFFF7F7F5),
        primaryText: Color(0xFF070707),
        secondary: Color(0xFF1A1A1A),
      );
    }

    return const AuthColors(
      background: Color(0xFFE8ECEE),
      backgroundShape: Color(0xFFD8DDDF),
      surface: Color(0xFFFAFAF8),
      text: Color(0xFF151515),
      muted: Color(0xFF777777),
      border: Color(0xFFE2E2DF),
      primary: Color(0xFF151515),
      primaryText: Color(0xFFFFFFFF),
      secondary: Color(0xFFFFFFFF),
    );
  }
}
