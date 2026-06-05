import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    _TabItem(
      icon: Iconsax.home_2_copy,
      activeIcon: Iconsax.home_2,
      label: 'Início',
    ),
    _TabItem(
      icon: Iconsax.book_copy,
      activeIcon: Iconsax.book,
      label: 'Lei Seca',
    ),
    _TabItem(
      icon: Iconsax.user_copy,
      activeIcon: Iconsax.user,
      label: 'Perfil',
    ),
    // Reativar depois:
    // _TabItem(
    //   icon: Iconsax.document_text_1_copy,
    //   activeIcon: Iconsax.document_text_1,
    //   label: 'Questões',
    // ),
    // _TabItem(
    //   icon: Iconsax.medal_star_copy,
    //   activeIcon: Iconsax.medal_star,
    //   label: 'Ranking',
    // ),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isNavVisible = true;

  void _setNavVisible(bool value) {
    if (_isNavVisible == value) return;
    setState(() => _isNavVisible = value);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        _setNavVisible(false);
      } else if (notification.direction == ScrollDirection.forward) {
        _setNavVisible(true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = widget.navigationShell.currentIndex;
    final isDark = theme.brightness == Brightness.dark;
    final navBackground = isDark ? Colors.white : Colors.black;
    final navForeground = isDark ? Colors.black : Colors.white;
    final navMuted = navForeground.withValues(alpha: 0.58);

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 36),
        child: SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: _isNavVisible ? Offset.zero : const Offset(0, 1.7),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                opacity: _isNavVisible ? 1 : 0,
                child: Container(
                  width: 132,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: navBackground,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: navForeground.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (
                        var index = 0;
                        index < AppShell._tabs.length;
                        index++
                      )
                        _FloatingNavButton(
                          tab: AppShell._tabs[index],
                          selected: currentIndex == index,
                          selectedColor: navForeground,
                          mutedColor: navMuted,
                          onTap: () {
                            widget.navigationShell.goBranch(
                              index,
                              initialLocation: index == currentIndex,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavButton extends StatelessWidget {
  final _TabItem tab;
  final bool selected;
  final Color selectedColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _FloatingNavButton({
    required this.tab,
    required this.selected,
    required this.selectedColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.label,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            selected ? tab.activeIcon : tab.icon,
            color: selected ? selectedColor : mutedColor,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
