import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

class AuthPageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(child: _AuthBackground(colors: colors)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _BackButton(colors: colors),
                            ),
                            const SizedBox(height: 22),
                            _AuthBrand(colors: colors),
                            const SizedBox(height: 34),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: colors.text,
                                fontSize: 30,
                                height: 1.04,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: colors.muted,
                                fontSize: 14,
                                height: 1.42,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 28),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: colors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 28,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  20,
                                  18,
                                  18,
                                ),
                                child: child,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  final AuthColors colors;

  const _AuthBackground({required this.colors});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.background),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -110,
            child: _SoftBlock(color: colors.backgroundShape),
          ),
          Positioned(
            left: -120,
            bottom: 100,
            child: _SoftBlock(color: colors.backgroundShape),
          ),
          Positioned(
            top: 92,
            left: 38,
            child: _SmallMark(color: colors.backgroundShape),
          ),
        ],
      ),
    );
  }
}

class _SoftBlock extends StatelessWidget {
  final Color color;

  const _SoftBlock({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(92),
      ),
    );
  }
}

class _SmallMark extends StatelessWidget {
  final Color color;

  const _SmallMark({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  final AuthColors colors;

  const _AuthBrand({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            'P',
            style: GoogleFonts.quicksand(
              color: colors.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'papirar',
          style: GoogleFonts.quicksand(
            color: colors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final AuthColors colors;

  const _BackButton({required this.colors});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.go('/splash'),
      style: IconButton.styleFrom(
        backgroundColor: colors.secondary,
        foregroundColor: colors.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: colors.border),
      ),
      icon: const Icon(Icons.arrow_back_rounded, size: 20),
      tooltip: 'Voltar',
    );
  }
}
