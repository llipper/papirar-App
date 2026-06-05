import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papirar/core/theme/app_theme_provider.dart';
import 'package:papirar/features/home/presentation/controllers/home_controller.dart';
import 'package:papirar/features/home/widgets/home_colors.dart';
import 'package:papirar/features/home/widgets/home_header.dart';
import 'package:papirar/features/home/widgets/home_markings_card.dart';
import 'package:papirar/features/home/widgets/home_reading_card.dart';
import 'package:papirar/features/home/widgets/home_review_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController()
      ..startSyncListener()
      ..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appThemeModeProvider);
    final isDark = ref.read(appThemeModeProvider.notifier).isDark(context);
    final colors = HomeColors.fromBrightness(isDark);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
              sliver: SliverList.list(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Column(
                        children: [
                          HomeHeader(
                            colors: colors,
                            profile: _controller.profile,
                            onToggleTheme: () => ref
                                .read(appThemeModeProvider.notifier)
                                .toggle(),
                          ),
                          const SizedBox(height: 24),
                          HomeReadingCard(
                            colors: colors,
                            reading: _controller.currentReading,
                            isLoading: _controller.isLoading,
                          ),
                          const SizedBox(height: 12),
                          HomeMarkingsCard(
                            colors: colors,
                            highlights: _controller.highlights,
                          ),
                          const SizedBox(height: 12),
                          HomeReviewCard(
                            colors: colors,
                            highlights: _controller.highlights,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
