import 'package:flutter/material.dart';

/// Arrastar da borda esquerda para voltar (sem conflitar com scroll vertical).
class LeiReadingBackGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onBack;

  const LeiReadingBackGesture({
    super.key,
    required this.child,
    required this.onBack,
  });

  @override
  State<LeiReadingBackGesture> createState() => _LeiReadingBackGestureState();
}

class _LeiReadingBackGestureState extends State<LeiReadingBackGesture> {
  static const double _edgeWidth = 28;
  static const double _minDrag = 72;

  double _accumulatedDrag = 0;

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_accumulatedDrag >= _minDrag || velocity > 420) {
      widget.onBack();
    }
    _accumulatedDrag = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _accumulatedDrag = 0,
            onHorizontalDragUpdate: (d) {
              if (d.delta.dx > 0) _accumulatedDrag += d.delta.dx;
            },
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragCancel: () => _accumulatedDrag = 0,
          ),
        ),
      ],
    );
  }
}