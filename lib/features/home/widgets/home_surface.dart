import 'package:flutter/material.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';

class HomeCardSurface extends StatelessWidget {
  final HomeColors colors;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HomeCardSurface({
    super.key,
    required this.colors,
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.line),
      ),
      child: child,
    );
  }
}

class HomeCircleButton extends StatelessWidget {
  final HomeColors colors;
  final IconData icon;
  final VoidCallback onTap;

  const HomeCircleButton({
    super.key,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: colors.text, size: 20),
        ),
      ),
    );
  }
}
