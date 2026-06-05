import 'package:flutter/material.dart';

class ProfileColors {
  final bool isDark;
  final Color background;
  final Color card;
  final Color inner;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentText;
  final Color coverTop;
  final Color coverBottom;
  final Color positive;

  const ProfileColors({
    required this.isDark,
    required this.background,
    required this.card,
    required this.inner,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentText,
    required this.coverTop,
    required this.coverBottom,
    required this.positive,
  });

  factory ProfileColors.from(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return isDark
        ? const ProfileColors(
            isDark: true,
            background: Color(0xFF050505),
            card: Color(0xFF141414),
            inner: Color(0xFF202020),
            line: Color(0xFF2A2A2A),
            text: Color(0xFFF5F5F0),
            muted: Color(0xFF8E8E87),
            accent: Color(0xFFF5F5F0),
            accentText: Color(0xFF050505),
            coverTop: Color(0xFF1A1A1A),
            coverBottom: Color(0xFF343434),
            positive: Color(0xFF7ED6A5),
          )
        : const ProfileColors(
            isDark: false,
            background: Color(0xFFF4F4F1),
            card: Color(0xFFFFFFFF),
            inner: Color(0xFFF0F0ED),
            line: Color(0xFFE1E1DC),
            text: Color(0xFF151515),
            muted: Color(0xFF6F6F6F),
            accent: Color(0xFF151515),
            accentText: Color(0xFFFFFFFF),
            coverTop: Color(0xFFD9DDD8),
            coverBottom: Color(0xFFBFC7C0),
            positive: Color(0xFF0F8F58),
          );
  }
}
