import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/core/config/app_router.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';
import 'package:papirar/features/home/widgets/home_surface.dart';
import 'package:papirar/features/lei_seca/progress/domain/lei_reading_progress.dart';

class HomeReadingCard extends StatelessWidget {
  final HomeColors colors;
  final LeiReadingProgress? reading;
  final bool isLoading;

  const HomeReadingCard({
    super.key,
    required this.colors,
    required this.reading,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final seconds = reading?.totalSeconds ?? 0;
    final progress = seconds <= 0 ? 0.0 : (seconds / 7200).clamp(0.0, 1.0);

    return HomeCardSurface(
      colors: colors,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tempo lendo',
                style: GoogleFonts.quicksand(
                  color: colors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                reading?.leiSigla ?? 'Lei Seca',
                style: GoogleFonts.quicksand(
                  color: colors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 168,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(230, 124),
                  painter: _SemiGaugePainter(
                    progress: progress,
                    track: colors.inner,
                    active: colors.accent,
                    line: colors.line,
                  ),
                ),
                Positioned(
                  top: 104,
                  child: Column(
                    children: [
                      Text(
                        isLoading ? '--' : _formatSeconds(seconds),
                        style: GoogleFonts.quicksand(
                          color: colors.text,
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      // const SizedBox(height: 30),
                      // Text(
                      //   reading?.leiTitle ?? 'Nenhuma leitura registrada',
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: GoogleFonts.quicksand(
                      //     color: colors.muted,
                      //     fontSize: 8,
                      //     fontWeight: FontWeight.w700,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.accentText,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => context.goNamed(AppRoutes.leiSeca),
              icon: const Icon(Icons.menu_book_rounded, size: 20),
              label: Text(
                reading == null ? 'Começar leitura' : 'Continuar leitura',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiGaugePainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color active;
  final Color line;

  const _SemiGaugePainter({
    required this.progress,
    required this.track,
    required this.active,
    required this.line,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(12, 18, size.width - 24, size.height * 1.72);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = track;
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = active;
    final thinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = line;

    canvas.drawArc(rect, math.pi, math.pi, false, basePaint);
    canvas.drawArc(rect, math.pi, math.pi * progress, false, activePaint);
    canvas.drawArc(rect.deflate(26), math.pi, math.pi, false, thinPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.track != track ||
        oldDelegate.active != active ||
        oldDelegate.line != line;
  }
}

String _formatSeconds(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  if (minutes < 60) return '${minutes}min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}min';
}
