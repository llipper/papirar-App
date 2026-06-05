import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papirar/features/auth/di/auth_module.dart';
import 'package:papirar/features/auth/domain/usecases/sign_out.dart';
import 'package:papirar/features/perfil/presentation/controllers/profile_controller.dart';
import 'package:papirar/features/perfil/presentation/services/profile_avatar_crop_service.dart';
import 'package:papirar/features/perfil/widgets/profile_activity_section.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';
import 'package:papirar/features/perfil/widgets/profile_edit_sheet.dart';
import 'package:papirar/features/perfil/widgets/profile_header_card.dart';
import 'package:papirar/features/perfil/widgets/profile_plan_card.dart';
import 'package:papirar/features/perfil/widgets/profile_top_bar.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final ProfileController _controller;
  final SignOut _signOut = AuthModule.signOut();
  final ProfileAvatarCropService _avatarCropService =
      ProfileAvatarCropService();

  @override
  void initState() {
    super.initState();
    _controller = ProfileController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final avatar = await _avatarCropService.pickAndCrop(context);
    if (avatar == null) return;

    final uploaded = await _controller.uploadAvatar(
      bytes: avatar.bytes,
      extension: avatar.extension,
    );
    if (!mounted || uploaded) return;
    _showMessage(_controller.errorMessage ?? 'Não foi possível enviar avatar.');
  }

  Future<void> _openEditSheet(ProfileColors colors) async {
    final profile = _controller.profile;
    if (profile == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return ProfileEditSheet(
          colors: colors,
          profile: profile,
          isSaving: _controller.isSaving,
          onSave: _controller.save,
        );
      },
    );

    if (!mounted || _controller.errorMessage == null) return;
    _showMessage(_controller.errorMessage!);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSignOut() async {
    final result = await _signOut();
    if (!mounted) return;

    _showMessage(result.message);
    if (result.isSuccess) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colors = ProfileColors.from(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final profile = _controller.profile;

            if (_controller.isLoading && profile == null) {
              return _ProfileLoadingView(
                colors: colors,
                onSignOut: _handleSignOut,
              );
            }

            if (profile == null) {
              return _ProfileErrorView(
                colors: colors,
                message:
                    _controller.errorMessage ?? 'Não foi possível carregar.',
                onRetry: _controller.load,
              );
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
                  sliver: SliverList.list(
                    children: [
                      ProfileTopBar(colors: colors, onSignOut: _handleSignOut),
                      const SizedBox(height: 16),
                      ProfileHeaderCard(
                        colors: colors,
                        profile: profile,
                        onEditProfile: () => _openEditSheet(colors),
                        onChangeAvatar: _pickAvatar,
                        isUploadingAvatar: _controller.isUploadingAvatar,
                      ),
                      const SizedBox(height: 18),
                      ProfilePlanCard(
                        colors: colors,
                        onOpenLeiSeca: () => context.go('/lei-seca'),
                      ),
                      const SizedBox(height: 18),
                      ProfileActivitySection(colors: colors),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  final ProfileColors colors;
  final VoidCallback onSignOut;

  const _ProfileLoadingView({required this.colors, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
          sliver: SliverList.list(
            children: [
              ProfileTopBar(colors: colors, onSignOut: onSignOut),
              const SizedBox(height: 16),
              _SkeletonBlock(colors: colors, height: 150, borderRadius: 24),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SkeletonBlock(
                    colors: colors,
                    width: 78,
                    height: 78,
                    borderRadius: 999,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBlock(
                          colors: colors,
                          height: 22,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 8),
                        _SkeletonBlock(
                          colors: colors,
                          width: 130,
                          height: 14,
                          borderRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SkeletonBlock(colors: colors, height: 112, borderRadius: 22),
              const SizedBox(height: 18),
              _SkeletonBlock(colors: colors, height: 190, borderRadius: 22),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final ProfileColors colors;
  final double? width;
  final double height;
  final double borderRadius;

  const _SkeletonBlock({
    required this.colors,
    required this.height,
    required this.borderRadius,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: colors.inner,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.line),
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final ProfileColors colors;
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({
    required this.colors,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.text),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
