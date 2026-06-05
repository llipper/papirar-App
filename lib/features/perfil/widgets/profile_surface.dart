import 'package:flutter/material.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';

class ProfileCardSurface extends StatelessWidget {
  final ProfileColors colors;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ProfileCardSurface({
    super.key,
    required this.colors,
    required this.child,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.line),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class ProfileCircleButton extends StatelessWidget {
  final ProfileColors colors;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileCircleButton({
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
