import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/core/config/app_router.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';
import 'package:papirar/features/home/widgets/home_surface.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';

class HomeHeader extends StatelessWidget {
  final HomeColors colors;
  final UserProfile? profile;
  final VoidCallback onToggleTheme;

  const HomeHeader({
    super.key,
    required this.colors,
    required this.profile,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: GoogleFonts.quicksand(
                  color: colors.muted,
                  fontSize: 26,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _firstName,
                style: GoogleFonts.quicksand(
                  color: colors.text,
                  fontSize: 32,
                  height: 1.04,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        HomeCircleButton(
          colors: colors,
          icon: colors.isDark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          onTap: onToggleTheme,
        ),
        const SizedBox(width: 10),
        _AvatarButton(
          colors: colors,
          profile: profile,
          onTap: () => context.goNamed(AppRoutes.perfil),
        ),
      ],
    );
  }

  String get _firstName {
    final name = profile?.displayName.trim();
    if (name == null || name.isEmpty) return 'Aluno';
    return name.split(RegExp(r'\s+')).first;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }
}

class _AvatarButton extends StatelessWidget {
  final HomeColors colors;
  final UserProfile? profile;
  final VoidCallback onTap;

  const _AvatarButton({
    required this.colors,
    required this.profile,
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
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.line),
            image: profile?.avatarUrl == null
                ? null
                : DecorationImage(
                    image: NetworkImage(profile!.avatarUrl!),
                    fit: BoxFit.cover,
                  ),
          ),
          child: profile?.avatarUrl == null
              ? Center(
                  child: Text(
                    profile?.initials ?? 'P',
                    style: GoogleFonts.quicksand(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
