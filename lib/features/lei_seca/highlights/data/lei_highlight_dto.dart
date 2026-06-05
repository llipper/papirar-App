import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';

class LeiHighlightDto {
  const LeiHighlightDto._();

  static LeiHighlight fromMap(Map<String, dynamic> map) {
    return LeiHighlight(
      id: map['id'] as String,
      leiId: map['lei_id'] as String,
      blocoIndex: map['bloco_index'] as int,
      partIndex: map['part_index'] as int,
      startOffset: map['start_offset'] as int,
      endOffset: map['end_offset'] as int,
      color: LeiHighlightColor.values.byName(map['color'] as String),
      selectedText: map['selected_text'] as String,
    );
  }
}
