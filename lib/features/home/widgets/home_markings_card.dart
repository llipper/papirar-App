import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';
import 'package:papirar/features/home/widgets/home_surface.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';

class HomeMarkingsCard extends StatelessWidget {
  final HomeColors colors;
  final List<LeiHighlight> highlights;

  const HomeMarkingsCard({
    super.key,
    required this.colors,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    return HomeCardSurface(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marcações',
            style: GoogleFonts.quicksand(
              color: colors.text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            highlights.isEmpty
                ? 'Marque trechos da lei para organizar sua revisão.'
                : 'Resumo dos trechos que você marcou na leitura.',
            style: GoogleFonts.quicksand(
              color: colors.muted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MarkingStat(
                  colors: colors,
                  color: LeiHighlightColor.yellow,
                  count: _count(LeiHighlightColor.yellow),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MarkingStat(
                  colors: colors,
                  color: LeiHighlightColor.red,
                  count: _count(LeiHighlightColor.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MarkingStat(
                  colors: colors,
                  color: LeiHighlightColor.blue,
                  count: _count(LeiHighlightColor.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MarkingStat(
                  colors: colors,
                  color: LeiHighlightColor.green,
                  count: _count(LeiHighlightColor.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _count(LeiHighlightColor color) {
    return highlights.where((item) => item.color == color).length;
  }
}

class _MarkingStat extends StatelessWidget {
  final HomeColors colors;
  final LeiHighlightColor color;
  final int count;

  const _MarkingStat({
    required this.colors,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.inner,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              color.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                color: colors.text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.quicksand(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
