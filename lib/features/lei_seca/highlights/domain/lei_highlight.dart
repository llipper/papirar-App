import 'package:flutter/material.dart';

enum LeiHighlightColor {
  yellow,
  red,
  blue,
  green;

  String get label {
    return switch (this) {
      LeiHighlightColor.yellow => 'Importante',
      LeiHighlightColor.red => 'Cai muito',
      LeiHighlightColor.blue => 'Revisar',
      LeiHighlightColor.green => 'Dominado',
    };
  }

  Color get backgroundColor {
    return switch (this) {
      LeiHighlightColor.yellow => const Color(0xFFFFE066),
      LeiHighlightColor.red => const Color(0xFFFF6B6B),
      LeiHighlightColor.blue => const Color(0xFF74C0FC),
      LeiHighlightColor.green => const Color(0xFF8CE99A),
    };
  }
}

class LeiHighlight {
  final String id;
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final int startOffset;
  final int endOffset;
  final LeiHighlightColor color;
  final String selectedText;

  const LeiHighlight({
    required this.id,
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.startOffset,
    required this.endOffset,
    required this.color,
    required this.selectedText,
  });
}

class CreateLeiHighlightInput {
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final int startOffset;
  final int endOffset;
  final LeiHighlightColor color;
  final String selectedText;

  const CreateLeiHighlightInput({
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.startOffset,
    required this.endOffset,
    required this.color,
    required this.selectedText,
  });
}

class LeiHighlightRangeInput {
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final int startOffset;
  final int endOffset;

  const LeiHighlightRangeInput({
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.startOffset,
    required this.endOffset,
  });
}
