import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';
import 'package:papirar/features/home/widgets/home_surface.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';

class HomeReviewCard extends StatelessWidget {
  final HomeColors colors;
  final List<LeiHighlight> highlights;

  const HomeReviewCard({
    super.key,
    required this.colors,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    final item = _priorityHighlight;

    return HomeCardSurface(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.inner,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item == null
                  ? Icons.auto_stories_outlined
                  : Icons.priority_high_rounded,
              color: colors.text,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? 'Próxima revisão' : item.color.label,
                  style: GoogleFonts.quicksand(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item?.selectedText ??
                      'Quando você marcar um trecho importante, ele aparece aqui para revisão rápida.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                    color: colors.muted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LeiHighlight? get _priorityHighlight {
    if (highlights.isEmpty) return null;

    for (final color in [
      LeiHighlightColor.red,
      LeiHighlightColor.yellow,
      LeiHighlightColor.blue,
      LeiHighlightColor.green,
    ]) {
      final filtered = highlights.where((item) => item.color == color);
      if (filtered.isNotEmpty) return filtered.first;
    }
    return highlights.first;
  }
}
