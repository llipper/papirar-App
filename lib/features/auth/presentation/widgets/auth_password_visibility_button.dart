import 'package:flutter/material.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

class AuthPasswordVisibilityButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;

  const AuthPasswordVisibilityButton({
    super.key,
    required this.isVisible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
      ),
      color: colors.muted,
      tooltip: isVisible ? 'Ocultar senha' : 'Mostrar senha',
    );
  }
}
