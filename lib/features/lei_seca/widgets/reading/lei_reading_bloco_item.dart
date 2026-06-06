import 'package:flutter/material.dart';
import 'package:papirar/domain/entities/lei_audio_explanation.dart';
import 'package:papirar/domain/entities/lei_texto.dart';
import 'package:papirar/features/lei_seca/config/lei_reading_layout_config.dart';
import 'package:papirar/features/lei_seca/controllers/lei_reading_controller.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_text_utils.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_paragraph.dart';

class LeiReadingBlocoItem extends StatelessWidget {
  final int blocoIndex;
  final String bloco;
  final List<LeiTextLinkRange> links;
  final bool useDropCap;
  final LeiReadingStyles styles;
  final String leiId;
  final LeiAudioExplanation? audioExplanation;
  final Map<String, List<LeiHighlight>> highlightsByPart;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;

  const LeiReadingBlocoItem({
    super.key,
    required this.blocoIndex,
    required this.bloco,
    this.links = const [],
    required this.useDropCap,
    required this.styles,
    required this.leiId,
    required this.highlightsByPart,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.audioExplanation,
  });

  @override
  Widget build(BuildContext context) {
    final partes = LeiReadingTextUtils.partes(bloco);
    final linksByPart = _linksByPart(partes);
    final audioPartIndex = _audioPartIndex(partes);
    final blocoPadding = LeiReadingTextUtils.ehRotuloArtigo(bloco)
        ? LeiReadingLayoutConfig.articleBlockPadding
        : LeiReadingLayoutConfig.defaultBlockPadding;

    return RepaintBoundary(
      child: Padding(
        padding: blocoPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildPartes(partes, linksByPart, audioPartIndex),
        ),
      ),
    );
  }

  List<Widget> _buildPartes(
    List<String> partes,
    Map<int, List<LeiTextLinkRange>> linksByPart,
    int audioPartIndex,
  ) {
    final children = <Widget>[];

    for (var p = 0; p < partes.length; p++) {
      final isRubrica =
          partes.length > 1 && LeiReadingTextUtils.ehProvavelRubrica(partes[p]);
      final nextHasHierarchy =
          p + 1 < partes.length &&
          (LeiReadingTextUtils.ehParagrafo(partes[p + 1]) ||
              LeiReadingTextUtils.ehIncisoRomano(partes[p + 1]) ||
              LeiReadingTextUtils.ehAlinea(partes[p + 1]));

      if (isRubrica && nextHasHierarchy) {
        final paragraphIndex = p + 1;
        if (p == audioPartIndex) {
          children.add(
            LeiReadingParagraph(
              blocoIndex: blocoIndex,
              partIndex: p,
              text: partes[p],
              useDropCap: false,
              styles: styles,
              leiId: leiId,
              highlights:
                  highlightsByPart[LeiReadingController.highlightKey(
                    blocoIndex,
                    p,
                  )] ??
                  const [],
              links: linksByPart[p] ?? const [],
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
              isRubrica: true,
              audioExplanation: audioExplanation,
            ),
          );
          children.add(
            LeiReadingParagraph(
              blocoIndex: blocoIndex,
              partIndex: paragraphIndex,
              text: partes[paragraphIndex],
              useDropCap: false,
              styles: styles,
              leiId: leiId,
              highlights:
                  highlightsByPart[LeiReadingController.highlightKey(
                    blocoIndex,
                    paragraphIndex,
                  )] ??
                  const [],
              links: linksByPart[paragraphIndex] ?? const [],
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
            ),
          );
          p = paragraphIndex;
          continue;
        }

        children.add(
          LeiReadingParagraph(
            blocoIndex: blocoIndex,
            partIndex: paragraphIndex,
            text: partes[paragraphIndex],
            useDropCap: false,
            styles: styles,
            leiId: leiId,
            highlights:
                highlightsByPart[LeiReadingController.highlightKey(
                  blocoIndex,
                  paragraphIndex,
                )] ??
                const [],
            links: linksByPart[paragraphIndex] ?? const [],
            onHighlight: onHighlight,
            onRemoveHighlight: onRemoveHighlight,
            rubricaText: partes[p],
            rubricaPartIndex: p,
            rubricaHighlights:
                highlightsByPart[LeiReadingController.highlightKey(
                  blocoIndex,
                  p,
                )] ??
                const [],
            rubricaLinks: linksByPart[p] ?? const [],
            audioExplanation: paragraphIndex == audioPartIndex
                ? audioExplanation
                : null,
          ),
        );
        p = paragraphIndex;
        continue;
      }

      children.add(
        LeiReadingParagraph(
          blocoIndex: blocoIndex,
          partIndex: p,
          text: partes[p],
          useDropCap: useDropCap && p == 0,
          styles: styles,
          leiId: leiId,
          highlights:
              highlightsByPart[LeiReadingController.highlightKey(
                blocoIndex,
                p,
              )] ??
              const [],
          links: linksByPart[p] ?? const [],
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
          isRubrica: isRubrica,
          audioExplanation: p == audioPartIndex ? audioExplanation : null,
        ),
      );
    }

    return children;
  }

  int _audioPartIndex(List<String> partes) {
    if (audioExplanation == null) return -1;
    if (partes.length > 1 &&
        LeiReadingTextUtils.ehProvavelRubrica(partes.first) &&
        LeiReadingTextUtils.ehIncisoRomano(partes[1])) {
      return 0;
    }

    return partes.indexWhere(
      (parte) => !LeiReadingTextUtils.ehProvavelRubrica(parte),
    );
  }

  Map<int, List<LeiTextLinkRange>> _linksByPart(List<String> partes) {
    if (links.isEmpty || partes.isEmpty) return const {};

    final result = <int, List<LeiTextLinkRange>>{};
    var offset = 0;

    for (var i = 0; i < partes.length; i++) {
      final start = offset;
      final end = start + partes[i].length;
      final partLinks = <LeiTextLinkRange>[];

      for (final link in links) {
        if (link.endOffset <= start || link.startOffset >= end) continue;
        final localStart = (link.startOffset - start)
            .clamp(0, partes[i].length)
            .toInt();
        final localEnd = (link.endOffset - start)
            .clamp(0, partes[i].length)
            .toInt();
        if (localStart >= localEnd) continue;
        partLinks.add(
          LeiTextLinkRange(
            startOffset: localStart,
            endOffset: localEnd,
            href: link.href,
          ),
        );
      }

      if (partLinks.isNotEmpty) result[i] = partLinks;
      offset = end + 2;
    }

    return result;
  }
}
