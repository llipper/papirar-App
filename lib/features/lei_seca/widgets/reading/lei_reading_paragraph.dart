import 'package:flutter/material.dart';
import 'package:papirar/features/lei_seca/audio/lei_audio_explanation.dart';
import 'package:papirar/features/lei_seca/audio/lei_audio_explanations.dart';
import 'package:papirar/features/lei_seca/config/lei_reading_layout_config.dart';
import 'package:papirar/features/lei_seca/highlights/domain/lei_highlight.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_styles.dart';
import 'package:papirar/features/lei_seca/utils/lei_reading_text_utils.dart';
import 'package:papirar/features/lei_seca/widgets/reading/lei_audio_explanation_button.dart';

class LeiReadingParagraph extends StatelessWidget {
  final int blocoIndex;
  final int partIndex;
  final String text;
  final bool useDropCap;
  final LeiReadingStyles styles;
  final String leiId;
  final List<LeiHighlight> highlights;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;
  final LeiAudioExplanation? audioExplanation;
  final bool isRubrica;
  final String? rubricaText;
  final int? rubricaPartIndex;
  final List<LeiHighlight> rubricaHighlights;

  const LeiReadingParagraph({
    super.key,
    required this.blocoIndex,
    required this.partIndex,
    required this.text,
    required this.useDropCap,
    required this.styles,
    required this.leiId,
    required this.highlights,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.audioExplanation,
    this.isRubrica = false,
    this.rubricaText,
    this.rubricaPartIndex,
    this.rubricaHighlights = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    // Never put drop-cap large letter on article labels ("Art. X") or titles.
    // The large first letter is only for the actual body text content.
    final isRotulo = LeiReadingTextUtils.ehRotuloArtigo(text);
    final resolvedAudioExplanation =
        audioExplanation ??
        LeiAudioExplanations.byText(leiId: leiId, text: text);
    if (useDropCap &&
        text.length > 1 &&
        !isRotulo &&
        !LeiReadingTextUtils.ehTitulo(text)) {
      return Padding(
        padding: LeiReadingLayoutConfig.dropCapPadding,
        child: _SelectableMarkedText(
          text: text,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
          textAlign: TextAlign.justify,
          spans: [
            _MarkedTextSegment(0, 1, styles.dropCap),
            _MarkedTextSegment(1, text.length, styles.body),
          ],
        ),
      );
    }

    if (LeiReadingTextUtils.ehTitulo(text)) {
      return Padding(
        padding: LeiReadingLayoutConfig.titlePadding,
        child: _TextWithAudioButton(
          text: text,
          style: styles.heading,
          explanation: resolvedAudioExplanation,
          alignment: WrapAlignment.center,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
        ),
      );
    }

    if (isRotulo) {
      // Style article labels ("Art. 2", "Art. 3º ...") distinctly so they stand out
      // from the body text and don't look like regular paragraphs.
      return Padding(
        padding: LeiReadingLayoutConfig.articleLabelPadding,
        child: _TextWithAudioButton(
          text: text,
          style: styles.body.copyWith(fontWeight: FontWeight.w600, height: 1.4),
          explanation: resolvedAudioExplanation,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
        ),
      );
    }

    if (isRubrica) {
      return Padding(
        padding: LeiReadingLayoutConfig.rubricaPadding,
        child: _TextWithAudioButton(
          text: text,
          style: styles.rubrica,
          explanation: resolvedAudioExplanation,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
        ),
      );
    }

    final contentSpans = _contentSpans(text);

    final hasRubricaText =
        rubricaText != null && rubricaText!.trim().isNotEmpty;
    final Widget content;

    if (resolvedAudioExplanation == null) {
      if (hasRubricaText) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: _rubricaPaddingFor(text),
              child: _SelectableMarkedText(
                text: rubricaText!,
                leiId: leiId,
                blocoIndex: blocoIndex,
                partIndex: rubricaPartIndex ?? partIndex,
                highlights: rubricaHighlights,
                onHighlight: onHighlight,
                onRemoveHighlight: onRemoveHighlight,
                baseStyle: _rubricaStyleFor(text),
              ),
            ),
            _SelectableMarkedText(
              text: text,
              leiId: leiId,
              blocoIndex: blocoIndex,
              partIndex: partIndex,
              highlights: highlights,
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
              textAlign: TextAlign.justify,
              baseStyle: styles.body,
              spans: contentSpans,
            ),
          ],
        );
      } else {
        content = _SelectableMarkedText(
          text: text,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
          textAlign: TextAlign.justify,
          baseStyle: styles.body,
          spans: contentSpans,
        );
      }
    } else {
      content = _ParagraphWithAudioButton(
        text: text,
        style: styles.body,
        strongPrefixStyle: _strongPrefixStyle(),
        explanation: resolvedAudioExplanation,
        leiId: leiId,
        blocoIndex: blocoIndex,
        partIndex: partIndex,
        highlights: highlights,
        onHighlight: onHighlight,
        onRemoveHighlight: onRemoveHighlight,
        rubricaText: rubricaText,
        rubricaPartIndex: rubricaPartIndex,
        rubricaHighlights: rubricaHighlights,
        rubricaPadding: _rubricaPaddingFor(text),
        rubricaStyle: _rubricaStyleFor(text),
      );
    }

    return Padding(padding: _contentPadding(text), child: content);
  }

  EdgeInsets _contentPadding(String text) {
    if (LeiReadingTextUtils.ehParagrafo(text)) {
      return LeiReadingLayoutConfig.paragraphPadding;
    }
    if (LeiReadingTextUtils.ehIncisoRomano(text)) {
      return LeiReadingLayoutConfig.incisoPadding;
    }
    return LeiReadingLayoutConfig.bodyTextPadding;
  }

  EdgeInsets _rubricaPaddingFor(String targetText) {
    if (LeiReadingTextUtils.ehAlinea(targetText)) {
      return LeiReadingLayoutConfig.rubricaAlineaPadding;
    }
    if (LeiReadingTextUtils.ehIncisoRomano(targetText)) {
      return LeiReadingLayoutConfig.rubricaIncisoPadding;
    }
    if (LeiReadingTextUtils.ehParagrafo(targetText)) {
      return LeiReadingLayoutConfig.rubricaParagraphPadding;
    }
    return LeiReadingLayoutConfig.rubricaPadding;
  }

  TextStyle _rubricaStyleFor(String targetText) {
    if (LeiReadingTextUtils.ehAlinea(targetText)) {
      return styles.rubrica.copyWith(
        color: styles.textColor.withValues(alpha: 0.58),
        fontSize: styles.rubrica.fontSize == null
            ? null
            : styles.rubrica.fontSize! * 0.94,
      );
    }
    if (LeiReadingTextUtils.ehIncisoRomano(targetText)) {
      return styles.rubrica.copyWith(
        color: styles.textColor.withValues(alpha: 0.66),
      );
    }
    if (LeiReadingTextUtils.ehParagrafo(targetText)) {
      return styles.rubrica.copyWith(
        color: styles.textColor.withValues(alpha: 0.72),
      );
    }
    return styles.rubrica;
  }

  TextStyle _strongPrefixStyle() {
    return styles.body.copyWith(
      color: styles.textColor,
      fontWeight: FontWeight.w700,
    );
  }

  List<_MarkedTextSegment>? _contentSpans(String text) {
    final prefixEnd = _strongPrefixEnd(text);
    if (prefixEnd == null) return null;

    return [
      _MarkedTextSegment(0, prefixEnd, _strongPrefixStyle()),
      _MarkedTextSegment(prefixEnd, text.length, styles.body),
    ];
  }

  int? _strongPrefixEnd(String text) {
    final paragrafoMatch = RegExp(
      r'^\s*(?:§\s*\d+º|Parágrafo único\.?)\s*-\s*',
      caseSensitive: false,
    ).firstMatch(text);
    if (paragrafoMatch != null) return paragrafoMatch.end;

    final incisoMatch = RegExp(r'^\s*-?\s*[IVXLCDM]+\s*-\s*').firstMatch(text);
    return incisoMatch?.end;
  }
}

class _ParagraphWithAudioButton extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextStyle strongPrefixStyle;
  final LeiAudioExplanation explanation;
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final List<LeiHighlight> highlights;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;
  final String? rubricaText;
  final int? rubricaPartIndex;
  final List<LeiHighlight> rubricaHighlights;
  final EdgeInsets rubricaPadding;
  final TextStyle rubricaStyle;

  const _ParagraphWithAudioButton({
    required this.text,
    required this.style,
    required this.strongPrefixStyle,
    required this.explanation,
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.highlights,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.rubricaText,
    this.rubricaPartIndex,
    this.rubricaHighlights = const [],
    required this.rubricaPadding,
    required this.rubricaStyle,
  });

  @override
  Widget build(BuildContext context) {
    final match = RegExp(
      r'^(§\s*\d+º|Parágrafo único\.?)\s*(?:-\s*)?(.*)$',
      caseSensitive: false,
    ).firstMatch(text.trim());

    if (match == null) {
      final textWithAudio = _TextWithAudioButton(
        text: text,
        style: style,
        spans: _spansForStrongPrefix(text, strongPrefixStyle, style),
        explanation: explanation,
        leiId: leiId,
        blocoIndex: blocoIndex,
        partIndex: partIndex,
        highlights: highlights,
        onHighlight: onHighlight,
        onRemoveHighlight: onRemoveHighlight,
      );
      if (rubricaText == null || rubricaText!.trim().isEmpty) {
        return textWithAudio;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: rubricaPadding,
            child: _SelectableMarkedText(
              text: rubricaText!,
              leiId: leiId,
              blocoIndex: blocoIndex,
              partIndex: rubricaPartIndex ?? partIndex,
              highlights: rubricaHighlights,
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
              baseStyle: rubricaStyle,
            ),
          ),
          textWithAudio,
        ],
      );
    }

    final label = match.group(1)!;
    final body = match.group(2)?.trim() ?? '';

    return _ParagraphLabelAudioText(
      label: label,
      body: body,
      style: style,
      strongPrefixStyle: strongPrefixStyle,
      explanation: explanation,
      highlights: highlights,
      leiId: leiId,
      blocoIndex: blocoIndex,
      partIndex: partIndex,
      onHighlight: onHighlight,
      onRemoveHighlight: onRemoveHighlight,
      rubricaText: rubricaText,
      rubricaPartIndex: rubricaPartIndex,
      rubricaHighlights: rubricaHighlights,
      rubricaPadding: rubricaPadding,
      rubricaStyle: rubricaStyle,
    );
  }
}

List<_MarkedTextSegment>? _spansForStrongPrefix(
  String text,
  TextStyle strongStyle,
  TextStyle bodyStyle,
) {
  final match = RegExp(r'^\s*-?\s*[IVXLCDM]+\s*-\s*').firstMatch(text);
  if (match == null) return null;

  return [
    _MarkedTextSegment(0, match.end, strongStyle),
    _MarkedTextSegment(match.end, text.length, bodyStyle),
  ];
}

class _ParagraphLabelAudioText extends StatelessWidget {
  final String label;
  final String body;
  final TextStyle style;
  final TextStyle strongPrefixStyle;
  final LeiAudioExplanation explanation;
  final List<LeiHighlight> highlights;
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;
  final String? rubricaText;
  final int? rubricaPartIndex;
  final List<LeiHighlight> rubricaHighlights;
  final EdgeInsets rubricaPadding;
  final TextStyle rubricaStyle;

  const _ParagraphLabelAudioText({
    required this.label,
    required this.body,
    required this.style,
    required this.strongPrefixStyle,
    required this.explanation,
    required this.highlights,
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.rubricaText,
    this.rubricaPartIndex,
    this.rubricaHighlights = const [],
    required this.rubricaPadding,
    required this.rubricaStyle,
  });

  @override
  Widget build(BuildContext context) {
    final hasInlineRubrica =
        rubricaText != null && rubricaText!.trim().isNotEmpty;

    if (hasInlineRubrica) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SelectableMarkedText(
                text: label,
                leiId: leiId,
                blocoIndex: blocoIndex,
                partIndex: partIndex,
                highlights: highlights,
                onHighlight: onHighlight,
                onRemoveHighlight: onRemoveHighlight,
                baseStyle: style,
                spans: [_MarkedTextSegment(0, label.length, strongPrefixStyle)],
              ),
              if (LeiReadingLayoutConfig.paragraphAudioPosition !=
                  LeiReadingAudioPosition.hidden) ...[
                const SizedBox(width: LeiReadingLayoutConfig.audioTextSpacing),
                LeiAudioExplanationButton(
                  explanation: explanation,
                  width: LeiReadingLayoutConfig.paragraphAudioButtonWidth,
                  height: LeiReadingLayoutConfig.paragraphAudioButtonHeight,
                  iconSize: LeiReadingLayoutConfig.paragraphAudioIconSize,
                ),
              ],
            ],
          ),
          Padding(
            padding: rubricaPadding,
            child: _SelectableMarkedText(
              text: rubricaText!,
              leiId: leiId,
              blocoIndex: blocoIndex,
              partIndex: rubricaPartIndex ?? partIndex,
              highlights: rubricaHighlights,
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
              baseStyle: rubricaStyle,
            ),
          ),
          if (body.isNotEmpty)
            _SelectableMarkedText(
              text: body,
              leiId: leiId,
              blocoIndex: blocoIndex,
              partIndex: partIndex,
              highlights: highlights,
              onHighlight: onHighlight,
              onRemoveHighlight: onRemoveHighlight,
              baseStyle: style,
              offsetBase: label.length + 1,
            ),
        ],
      );
    }

    if (LeiReadingLayoutConfig.paragraphAudioPosition ==
        LeiReadingAudioPosition.hidden) {
      final text = body.isEmpty ? label : '$label - $body';
      final prefixEnd = body.isEmpty ? label.length : '$label - '.length;
      return _SelectableMarkedText(
        text: text,
        leiId: leiId,
        blocoIndex: blocoIndex,
        partIndex: partIndex,
        highlights: highlights,
        onHighlight: onHighlight,
        onRemoveHighlight: onRemoveHighlight,
        textAlign: TextAlign.justify,
        baseStyle: style,
        spans: [
          _MarkedTextSegment(0, prefixEnd, strongPrefixStyle),
          _MarkedTextSegment(prefixEnd, text.length, style),
        ],
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: LeiReadingLayoutConfig.audioTextSpacing,
      children: [
        _SelectableMarkedText(
          text: label,
          leiId: leiId,
          blocoIndex: blocoIndex,
          partIndex: partIndex,
          highlights: highlights,
          onHighlight: onHighlight,
          onRemoveHighlight: onRemoveHighlight,
          baseStyle: strongPrefixStyle,
        ),
        LeiAudioExplanationButton(
          explanation: explanation,
          width: LeiReadingLayoutConfig.paragraphAudioButtonWidth,
          height: LeiReadingLayoutConfig.paragraphAudioButtonHeight,
          iconSize: LeiReadingLayoutConfig.paragraphAudioIconSize,
        ),
        if (body.isNotEmpty)
          _SelectableMarkedText(
            text: body,
            leiId: leiId,
            blocoIndex: blocoIndex,
            partIndex: partIndex,
            highlights: highlights,
            onHighlight: onHighlight,
            onRemoveHighlight: onRemoveHighlight,
            baseStyle: style,
            offsetBase: label.length + 1,
          ),
      ],
    );
  }
}

class _TextWithAudioButton extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<_MarkedTextSegment>? spans;
  final LeiAudioExplanation? explanation;
  final WrapAlignment alignment;
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final List<LeiHighlight> highlights;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;

  const _TextWithAudioButton({
    required this.text,
    required this.style,
    this.spans,
    required this.explanation,
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.highlights,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final inlineAudioParts = _splitAudioPrefix(text);

    if (explanation == null ||
        LeiReadingLayoutConfig.audioPosition ==
            LeiReadingAudioPosition.hidden) {
      return _SelectableMarkedText(
        text: text,
        leiId: leiId,
        blocoIndex: blocoIndex,
        partIndex: partIndex,
        highlights: highlights,
        onHighlight: onHighlight,
        onRemoveHighlight: onRemoveHighlight,
        textAlign: alignment == WrapAlignment.center
            ? TextAlign.center
            : TextAlign.start,
        baseStyle: style,
        spans: spans,
      );
    }

    final audioButton = LeiAudioExplanationButton(explanation: explanation!);
    if (inlineAudioParts != null) {
      return Wrap(
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: LeiReadingLayoutConfig.audioTextSpacing,
        children: [
          _SelectableMarkedText(
            text: inlineAudioParts.label,
            leiId: leiId,
            blocoIndex: blocoIndex,
            partIndex: partIndex,
            highlights: highlights,
            onHighlight: onHighlight,
            onRemoveHighlight: onRemoveHighlight,
            baseStyle: spans?.first.style ?? style,
          ),
          audioButton,
          _SelectableMarkedText(
            text: inlineAudioParts.body,
            leiId: leiId,
            blocoIndex: blocoIndex,
            partIndex: partIndex,
            highlights: highlights,
            onHighlight: onHighlight,
            onRemoveHighlight: onRemoveHighlight,
            baseStyle: style,
            offsetBase: inlineAudioParts.bodyOffset,
          ),
        ],
      );
    }

    final textWidget = _SelectableMarkedText(
      text: text,
      leiId: leiId,
      blocoIndex: blocoIndex,
      partIndex: partIndex,
      highlights: highlights,
      onHighlight: onHighlight,
      onRemoveHighlight: onRemoveHighlight,
      baseStyle: style,
      spans: spans,
    );
    if (LeiReadingLayoutConfig.audioPosition ==
        LeiReadingAudioPosition.inlineBeforeText) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          audioButton,
          const SizedBox(width: LeiReadingLayoutConfig.audioTextSpacing),
          Expanded(child: textWidget),
        ],
      );
    }

    final children =
        LeiReadingLayoutConfig.audioPosition ==
            LeiReadingAudioPosition.inlineBeforeText
        ? [audioButton, textWidget]
        : [textWidget, audioButton];

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: LeiReadingLayoutConfig.audioTextSpacing,
      children: children,
    );
  }
}

_InlineAudioParts? _splitAudioPrefix(String text) {
  final match = RegExp(r'^(\s*[IVXLCDM]+)\s*-\s*(.+)$').firstMatch(text);
  if (match == null) return null;

  final label = match.group(1)!.trim();
  final body = match.group(2)!.trim();
  if (body.isEmpty) return null;

  return _InlineAudioParts(
    label: label,
    body: body,
    bodyOffset: match.start + match.group(0)!.indexOf(body),
  );
}

class _InlineAudioParts {
  final String label;
  final String body;
  final int bodyOffset;

  const _InlineAudioParts({
    required this.label,
    required this.body,
    required this.bodyOffset,
  });
}

class _MarkedTextSegment {
  final int start;
  final int end;
  final TextStyle style;

  const _MarkedTextSegment(this.start, this.end, this.style);
}

class _SelectableMarkedText extends StatefulWidget {
  final String text;
  final String leiId;
  final int blocoIndex;
  final int partIndex;
  final List<LeiHighlight> highlights;
  final Future<void> Function(CreateLeiHighlightInput input) onHighlight;
  final Future<void> Function(LeiHighlightRangeInput input) onRemoveHighlight;
  final TextAlign textAlign;
  final TextStyle? baseStyle;
  final List<_MarkedTextSegment>? spans;
  final int offsetBase;

  const _SelectableMarkedText({
    required this.text,
    required this.leiId,
    required this.blocoIndex,
    required this.partIndex,
    required this.highlights,
    required this.onHighlight,
    required this.onRemoveHighlight,
    this.textAlign = TextAlign.start,
    this.baseStyle,
    this.spans,
    this.offsetBase = 0,
  });

  @override
  State<_SelectableMarkedText> createState() => _SelectableMarkedTextState();
}

class _SelectableMarkedTextState extends State<_SelectableMarkedText> {
  TextSelection _selection = const TextSelection.collapsed(offset: -1);

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(children: _buildSpans()),
      textAlign: widget.textAlign,
      onSelectionChanged: (selection, _) {
        _selection = selection;
      },
      contextMenuBuilder: (context, editableTextState) {
        final items = <ContextMenuButtonItem>[
          ContextMenuButtonItem(
            label: 'Desmarcar',
            onPressed: () {
              editableTextState.hideToolbar();
              _remove();
            },
          ),
          for (final color in LeiHighlightColor.values)
            ContextMenuButtonItem(
              label: color.label,
              onPressed: () {
                editableTextState.hideToolbar();
                _mark(color);
              },
            ),
        ];

        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: items,
        );
      },
    );
  }

  Future<void> _remove() async {
    final range = _selectedGlobalRange();
    if (range == null) return;
    await widget.onRemoveHighlight(range);
  }

  Future<void> _mark(LeiHighlightColor color) async {
    final range = _selectedGlobalRange();
    if (range == null) return;

    final localStart = range.startOffset - widget.offsetBase;
    final localEnd = range.endOffset - widget.offsetBase;
    final selectedText = widget.text.substring(localStart, localEnd);
    if (selectedText.trim().isEmpty) return;

    await widget.onHighlight(
      CreateLeiHighlightInput(
        leiId: widget.leiId,
        blocoIndex: widget.blocoIndex,
        partIndex: widget.partIndex,
        startOffset: range.startOffset,
        endOffset: range.endOffset,
        color: color,
        selectedText: selectedText,
      ),
    );
  }

  LeiHighlightRangeInput? _selectedGlobalRange() {
    final start = _selection.start;
    final end = _selection.end;
    if (start < 0 || end < 0 || start == end) return null;

    final normalizedStart = start < end ? start : end;
    final normalizedEnd = start < end ? end : start;
    if (normalizedEnd > widget.text.length) return null;

    return LeiHighlightRangeInput(
      leiId: widget.leiId,
      blocoIndex: widget.blocoIndex,
      partIndex: widget.partIndex,
      startOffset: widget.offsetBase + normalizedStart,
      endOffset: widget.offsetBase + normalizedEnd,
    );
  }

  List<InlineSpan> _buildSpans() {
    final segments =
        widget.spans ??
        [_MarkedTextSegment(0, widget.text.length, widget.baseStyle!)];
    final spans = <InlineSpan>[];

    for (final segment in segments) {
      final start = segment.start.clamp(0, widget.text.length);
      final end = segment.end.clamp(0, widget.text.length);
      if (start >= end) continue;

      final globalStart = widget.offsetBase + start;
      final globalEnd = widget.offsetBase + end;
      final highlights =
          widget.highlights
              .where(
                (h) => h.endOffset > globalStart && h.startOffset < globalEnd,
              )
              .toList()
            ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

      var cursor = start;
      for (final highlight in highlights) {
        final highlightStart = (highlight.startOffset - widget.offsetBase)
            .clamp(start, end);
        final highlightEnd = (highlight.endOffset - widget.offsetBase).clamp(
          start,
          end,
        );
        if (highlightStart > cursor) {
          spans.add(
            TextSpan(
              text: widget.text.substring(cursor, highlightStart),
              style: segment.style,
            ),
          );
        }
        if (highlightEnd > highlightStart) {
          spans.add(
            TextSpan(
              text: widget.text.substring(highlightStart, highlightEnd),
              style: segment.style.copyWith(
                backgroundColor: highlight.color.backgroundColor.withValues(
                  alpha: 0.58,
                ),
              ),
            ),
          );
          cursor = highlightEnd;
        }
      }

      if (cursor < end) {
        spans.add(
          TextSpan(
            text: widget.text.substring(cursor, end),
            style: segment.style,
          ),
        );
      }
    }

    return spans;
  }
}
