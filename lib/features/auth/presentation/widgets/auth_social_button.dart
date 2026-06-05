import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

class AuthSocialButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AuthSocialButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.secondary,
          foregroundColor: colors.text,
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'G',
              style: GoogleFonts.quicksand(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Entrar com Google',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
