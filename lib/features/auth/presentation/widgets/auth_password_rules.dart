import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

class AuthPasswordRules extends StatelessWidget {
  const AuthPasswordRules({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          'Senha: mínimo 12 caracteres, maiúscula, minúscula, número e símbolo.',
          style: GoogleFonts.quicksand(
            color: colors.muted,
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
