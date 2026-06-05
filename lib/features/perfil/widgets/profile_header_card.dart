import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';

class ProfileHeaderCard extends StatelessWidget {
  final ProfileColors colors;
  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeAvatar;
  final bool isUploadingAvatar;

  const ProfileHeaderCard({
    super.key,
    required this.colors,
    required this.profile,
    required this.onEditProfile,
    required this.onChangeAvatar,
    required this.isUploadingAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _ProfileCover(colors: colors),
            Positioned(
              left: 16,
              bottom: -34,
              child: _ProfileAvatar(
                colors: colors,
                profile: profile,
                onTap: onChangeAvatar,
                isUploading: isUploadingAvatar,
              ),
            ),
            Positioned(
              right: 14,
              bottom: -22,
              child: _EditProfileButton(colors: colors, onTap: onEditProfile),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Text(
          profile.displayName,
          style: GoogleFonts.quicksand(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '@${profile.username}',
          style: GoogleFonts.quicksand(
            color: colors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          profile.bio.isEmpty
              ? 'Lei seca com áudio, revisão diária e foco em aprovação.'
              : profile.bio,
          style: GoogleFonts.quicksand(
            color: colors.text,
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _ProfileMeta(
              colors: colors,
              icon: Icons.menu_book_rounded,
              label: 'Lei seca',
            ),
            _ProfileMeta(
              colors: colors,
              icon: Icons.headphones_rounded,
              label: 'Áudio ativo',
            ),
            _ProfileMeta(
              colors: colors,
              icon: Icons.calendar_month_rounded,
              label: _createdAtLabel(profile.createdAt),
            ),
          ],
        ),
      ],
    );
  }

  String _createdAtLabel(DateTime? createdAt) {
    if (createdAt == null) return 'Perfil ativo';
    return 'Entrou em ${createdAt.year}';
  }
}

class _ProfileCover extends StatelessWidget {
  final ProfileColors colors;

  const _ProfileCover({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.line),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.coverTop, colors.coverBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 18,
            child: _CoverBookMark(colors: colors, title: 'CP'),
          ),
          Positioned(
            top: 44,
            left: 96,
            child: _CoverBookMark(colors: colors, title: 'CF'),
          ),
          Positioned(
            right: 18,
            bottom: 18,
            child: _CoverAudioPill(colors: colors),
          ),
        ],
      ),
    );
  }
}

class _CoverBookMark extends StatelessWidget {
  final ProfileColors colors;
  final String title;

  const _CoverBookMark({required this.colors, required this.title});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        width: 58,
        height: 72,
        decoration: BoxDecoration(
          color: colors.card.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.line),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.quicksand(
            color: colors.text,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CoverAudioPill extends StatelessWidget {
  final ProfileColors colors;

  const _CoverAudioPill({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: colors.text, size: 18),
          const SizedBox(width: 4),
          Text(
            'Lei seca com áudio',
            style: GoogleFonts.quicksand(
              color: colors.text,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ProfileColors colors;
  final UserProfile profile;
  final VoidCallback onTap;
  final bool isUploading;

  const _ProfileAvatar({
    required this.colors,
    required this.profile,
    required this.onTap,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: colors.background,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 5),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: colors.line),
                image: profile.avatarUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(profile.avatarUrl!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: profile.avatarUrl == null
                  ? Center(
                      child: Text(
                        profile.initials,
                        style: GoogleFonts.quicksand(
                          color: colors.accentText,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colors.card,
                shape: BoxShape.circle,
                border: Border.all(color: colors.background, width: 3),
              ),
              child: isUploading
                  ? Padding(
                      padding: const EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.text,
                      ),
                    )
                  : Icon(
                      Icons.camera_alt_rounded,
                      color: colors.text,
                      size: 14,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  final ProfileColors colors;
  final VoidCallback onTap;

  const _EditProfileButton({required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.card,
          foregroundColor: colors.text,
          side: BorderSide(color: colors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Text(
          'Editar perfil',
          style: GoogleFonts.quicksand(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ProfileMeta extends StatelessWidget {
  final ProfileColors colors;
  final IconData icon;
  final String label;

  const _ProfileMeta({
    required this.colors,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: colors.muted, size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.quicksand(
            color: colors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
