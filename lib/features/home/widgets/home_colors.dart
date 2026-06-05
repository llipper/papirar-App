import 'package:flutter/material.dart';

class HomeColors {
  final bool isDark;
  final Color background;
  final Color card;
  final Color inner;
  final Color line;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentText;

  const HomeColors({
    required this.isDark,
    required this.background,
    required this.card,
    required this.inner,
    required this.line,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentText,
  });

  factory HomeColors.fromBrightness(bool isDark) {
    return isDark
        ? const HomeColors(
            isDark: true,
            background: Color(0xFF050505),
            card: Color(0xFF141414),
            inner: Color(0xFF202020),
            line: Color(0xFF2A2A2A),
            text: Color(0xFFF5F5F0),
            muted: Color(0xFF8E8E87),
            accent: Color(0xFFF5F5F0),
            accentText: Color(0xFF050505),
          )
        : const HomeColors(
            isDark: false,
            background: Color(0xFFFFFFFF),
            card: Color(0xFFFFFFFF),
            inner: Color(0xFFF2F2F2),
            line: Color(0xFFE7E7E7),
            text: Color(0xFF151515),
            muted: Color(0xFF6F6F6F),
            accent: Color(0xFF151515),
            accentText: Color(0xFFFFFFFF),
          );
  }
}
