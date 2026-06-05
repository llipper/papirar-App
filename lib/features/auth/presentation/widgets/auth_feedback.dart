import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

void showAuthFeedback(BuildContext context, String message) {
  final colors = AuthColors.of(context);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.primary,
        content: Text(
          message,
          style: GoogleFonts.quicksand(
            color: colors.primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
}
