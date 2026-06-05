import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/lei_seca/controllers/lei_reading_controller.dart';
import 'package:papirar/features/lei_seca/widgets/reading/reading_text_size_sheet.dart';

/// Altura reservada para a lista não ficar sob a barra + área segura.
class ReadingBottomBarLayout {
  ReadingBottomBarLayout._();

  static const double barHeight = 70;
  static const double controlsHeight = 44;
  static const double chevronHeight = 22;
  static const double verticalMargin = 12;
  static const double horizontalMargin = 18;

  static double reservedBottom(BuildContext context) {
    return barHeight +
        verticalMargin * 2 +
        MediaQuery.paddingOf(context).bottom;
  }
}

class ReadingBottomBar extends StatelessWidget {
  final bool isDark;
  final String formattedTime;
  final LeiReadingMode mode;
  final double textSize;
  final VoidCallback onToggleMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<double> onTextSizeChanged;
  final VoidCallback? onCollapse;

  const ReadingBottomBar({
    super.key,
    required this.isDark,
    required this.formattedTime,
    required this.mode,
    required this.textSize,
    required this.onToggleMode,
    required this.onToggleTheme,
    required this.onTextSizeChanged,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _ReadingBarPalette.fromBrightness(isDark);
    final isListening = mode == LeiReadingMode.listen;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      minimum: const EdgeInsets.only(
        left: ReadingBottomBarLayout.horizontalMargin,
        right: ReadingBottomBarLayout.horizontalMargin,
        bottom: ReadingBottomBarLayout.verticalMargin,
      ),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: ReadingBottomBarLayout.barHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: ReadingBottomBarLayout.controlsHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimePill(palette: palette, formattedTime: formattedTime),
                    const SizedBox(width: 8),
                    _ModeToggle(
                      palette: palette,
                      isListening: isListening,
                      onToggle: onToggleMode,
                    ),
                    const SizedBox(width: 8),
                    _RoundActionButton(
                      tooltip: isDark ? 'Tema claro' : 'Tema escuro',
                      icon: Icons.brightness_6_outlined,
                      palette: palette,
                      onPressed: onToggleTheme,
                    ),
                    const SizedBox(width: 8),
                    _RoundActionButton(
                      tooltip: 'Tamanho do texto',
                      icon: Icons.text_fields,
                      palette: palette,
                      onPressed: () => ReadingTextSizeSheet.show(
                        context,
                        isDark: isDark,
                        textSize: textSize,
                        onTextSizeChanged: onTextSizeChanged,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ReadingBottomBarLayout.chevronHeight,
                child: IconButton(
                  tooltip: 'Ocultar controles',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 44,
                    height: ReadingBottomBarLayout.chevronHeight,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: palette.chevron,
                    size: 24,
                  ),
                  onPressed: onCollapse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingBarPalette {
  final Color control;
  final Color onControl;
  final Color selected;
  final Color onSelected;
  final Color inactive;
  final Color border;
  final Color chevron;
  final List<BoxShadow> shadow;

  const _ReadingBarPalette({
    required this.control,
    required this.onControl,
    required this.selected,
    required this.onSelected,
    required this.inactive,
    required this.border,
    required this.chevron,
    required this.shadow,
  });

  factory _ReadingBarPalette.fromBrightness(bool isDark) {
    return _ReadingBarPalette(
      control: isDark ? const Color(0xFF0D0D0F) : Colors.black,
      onControl: Colors.white,
      selected: Colors.white,
      onSelected: Colors.black,
      inactive: Colors.white.withValues(alpha: 0.72),
      border: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08),
      chevron: isDark
          ? Colors.white.withValues(alpha: 0.82)
          : Colors.black.withValues(alpha: 0.78),
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _TimePill extends StatelessWidget {
  final _ReadingBarPalette palette;
  final String formattedTime;

  const _TimePill({required this.palette, required this.formattedTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: ReadingBottomBarLayout.controlsHeight,
      decoration: BoxDecoration(
        color: palette.control,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
        boxShadow: palette.shadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 16, color: palette.onControl),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              formattedTime,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.onControl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _ReadingBarPalette palette;
  final bool isListening;
  final VoidCallback onToggle;

  const _ModeToggle({
    required this.palette,
    required this.isListening,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 116,
        height: ReadingBottomBarLayout.controlsHeight,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: palette.control,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.border),
          boxShadow: palette.shadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeChip(
                label: 'Read',
                selected: !isListening,
                palette: palette,
              ),
            ),
            Expanded(
              child: _ModeChip(
                label: 'Listen',
                selected: isListening,
                palette: palette,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final _ReadingBarPalette palette;

  const _ModeChip({
    required this.label,
    required this.selected,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? palette.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.quicksand(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected ? palette.onSelected : palette.inactive,
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final _ReadingBarPalette palette;
  final VoidCallback onPressed;

  const _RoundActionButton({
    required this.tooltip,
    required this.icon,
    required this.palette,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        customBorder: const CircleBorder(),
        child: Container(
          width: ReadingBottomBarLayout.controlsHeight,
          height: ReadingBottomBarLayout.controlsHeight,
          decoration: BoxDecoration(
            color: palette.control,
            shape: BoxShape.circle,
            border: Border.all(color: palette.border),
            boxShadow: palette.shadow,
          ),
          child: Icon(icon, color: palette.onControl, size: 20),
        ),
      ),
    );
  }
}
