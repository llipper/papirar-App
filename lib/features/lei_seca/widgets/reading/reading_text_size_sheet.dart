import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bottom sheet de tamanho de fonte (leitura).
class ReadingTextSizeSheet extends StatefulWidget {
  final bool isDark;
  final double textSize;
  final ValueChanged<double> onTextSizeChanged;

  const ReadingTextSizeSheet({
    super.key,
    required this.isDark,
    required this.textSize,
    required this.onTextSizeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isDark,
    required double textSize,
    required ValueChanged<double> onTextSizeChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ReadingTextSizeSheet(
        isDark: isDark,
        textSize: textSize,
        onTextSizeChanged: onTextSizeChanged,
      ),
    );
  }

  @override
  State<ReadingTextSizeSheet> createState() => _ReadingTextSizeSheetState();
}

class _ReadingTextSizeSheetState extends State<ReadingTextSizeSheet> {
  late double _size;

  @override
  void initState() {
    super.initState();
    _size = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tamanho do Texto',
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('A', style: TextStyle(fontSize: 14, color: textColor)),
              Expanded(
                child: Slider(
                  value: _size,
                  min: 12,
                  max: 32,
                  activeColor: textColor,
                  inactiveColor: textColor.withValues(alpha: 0.2),
                  onChanged: (value) {
                    setState(() => _size = value);
                    widget.onTextSizeChanged(value);
                  },
                ),
              ),
              Text('A', style: TextStyle(fontSize: 24, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}