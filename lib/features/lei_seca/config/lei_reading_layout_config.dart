import 'package:flutter/material.dart';

enum LeiReadingAudioPosition { inlineBeforeText, inlineAfterText, hidden }

abstract final class LeiReadingLayoutConfig {
  // Posição do botão de áudio em relação ao texto.
  static const audioPosition = LeiReadingAudioPosition.inlineAfterText;

  // Posição do áudio em parágrafos: exemplo "§ 1º" e "Parágrafo único".
  static const paragraphAudioPosition =
      LeiReadingAudioPosition.inlineBeforeText;

  // Espaço geral da lista de leitura: left, top, right, bottom.
  static const listPadding = EdgeInsets.fromLTRB(14.0, 44.0, 14.0, 16.0);
  static const listCacheExtent = 1200.0;

  // Espaço externo do bloco de artigo: left, top, right, bottom.
  static const articleBlockPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 3.0);

  // Espaço externo do bloco comum: left, top, right, bottom.
  static const defaultBlockPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0);

  // Espaço do primeiro texto com letra capitular: left, top, right, bottom.
  static const dropCapPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0);

  // Espaço dos títulos e divisões da lei: left, top, right, bottom.
  static const titlePadding = EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 22.0);

  // Espaço do rótulo do artigo, exemplo "Art. 7º": left, top, right, bottom.
  static const articleLabelPadding = EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 6.0);

  // Espaço da rubrica do artigo/inciso/parágrafo: left, top, right, bottom.
  static const rubricaPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0);

  // Espaço do parágrafo com "§" ou "Parágrafo único": left, top, right, bottom.
  static const paragraphPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0);

  // Espaço do inciso romano, exemplo "I", "II", "III": left, top, right, bottom.
  static const incisoPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0);

  // Espaço do texto comum/caput: left, top, right, bottom.
  static const bodyTextPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0);

  // Espaço e tamanho do botão de áudio.
  static const audioTextSpacing = 4.0;
  static const audioButtonWidth = 40.0;
  static const audioButtonHeight = 24.0;
  // Espaço interno do botão de áudio: left, top, right, bottom.
  static const audioButtonPadding = EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0);
  static const audioIconSize = 24.0;
  static const paragraphAudioButtonWidth = 28.0;
  static const paragraphAudioButtonHeight = 24.0;
  static const paragraphAudioIconSize = 24.0;
  static const audioLoadingSize = 18.0;
  static const audioLoadingStrokeWidth = 2.0;

  // Densidade visual do botão de áudio.
  static const audioButtonVisualDensity = VisualDensity.compact;
}
