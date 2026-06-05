import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';
import 'package:papirar/features/perfil/widgets/profile_surface.dart';

class ProfileTopBar extends StatelessWidget {
  final ProfileColors colors;
  final VoidCallback onSignOut;

  const ProfileTopBar({
    super.key,
    required this.colors,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ProfileCircleButton(
        //   colors: colors,
        //   icon: Icons.arrow_back_ios_new_rounded,
        //   onTap: () {
        //     if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        //   },
        // ),
        const SizedBox(width: 12),
        Text(
          'Papirar',
          style: GoogleFonts.quicksand(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        ProfileCircleButton(
          colors: colors,
          icon: Icons.logout_rounded,
          onTap: onSignOut,
        ),
      ],
    );
  }
}
