import 'package:flutter/material.dart';
import 'package:papirar/domain/entities/lei_audio_explanation.dart';
import 'package:papirar/domain/entities/lei_texto.dart';
import 'package:papirar/features/lei_seca/config/lei_reading_layout_config.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_text_utils.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_bloco_item.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_reading_header.dart';

class LeiReadingContentList extends StatelessWidget {
  final ScrollController scrollController;
  final List<String> blocos;
  final Map<int, LeiAudioExplanation> audiosPorBloco;
  final Map<int, List<LeiTextLinkRange>> linksPorBloco;
  final String leiId;
  final String sigla;
  final String titulo;
  final LeiReadingStyles styles;
  final double bottomPadding;
  final VoidCallback onBack;
  final Map<String, List<LeiHighlight>> highlightsByPart;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;

  const LeiReadingContentList({
    super.key,
    required this.scrollController,
    required this.blocos,
    required this.audiosPorBloco,
    required this.linksPorBloco,
    required this.leiId,
    required this.sigla,
    required this.titulo,
    required this.styles,
    required this.bottomPadding,
    required this.onBack,
    required this.highlightsByPart,
    required this.onHighlight,
    required this.onRemoveHighlight,
  });

  @override
  Widget build(BuildContext context) {
    final dropCapIndex = LeiReadingTextUtils.primeiroBlocoLongo(blocos);
    const listPadding = LeiReadingLayoutConfig.listPadding;

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        listPadding.left,
        listPadding.top,
        listPadding.right,
        bottomPadding + listPadding.bottom,
      ),
      cacheExtent: LeiReadingLayoutConfig.listCacheExtent,
      itemCount: blocos.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return LeiReadingHeader(
            sigla: sigla,
            titulo: titulo,
            textColor: styles.textColor,
            onBack: onBack,
          );
        }

        final blocoIndex = index - 1;
        return LeiReadingBlocoItem(
          blocoIndex: blocoIndex,
          bloco: blocos[blocoIndex],
          links: linksPorBloco[blocoIndex] ?? const [],
          useDropCap: blocoIndex == dropCapIndex,
          styles: styles,
          leiId: leiId,
          audioExplanation: audiosPorBloco[blocoIndex],
          highlightsByPart: highlightsByPart,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
        );
      },
    );
  }
}
