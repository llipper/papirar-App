import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/lei_seca/models/lei_model.dart';
import 'package:papirar/features/lei_seca/widgets/lei_book_card.dart';
import 'package:papirar/features/lei_seca/lei_reading_screen.dart';

class LeiCategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<LeiModel> leis;
  final Color overlayColor;

  const LeiCategorySection({
    super.key,
    required this.categoryTitle,
    required this.leis,
    required this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${leis.length} leis',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_left,
                      size: 16, color: textColor.withValues(alpha: 0.5)),
                  Icon(Icons.chevron_right,
                      size: 16, color: textColor.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190, // Card height (170) + padding
          child: Stack(
            alignment: Alignment.center,
            children: [
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: leis.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  return LeiBookCard(
                    lei: leis[index],
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        PageRouteBuilder<void>(
                          opaque: true,
                          fullscreenDialog: false,
                          transitionDuration: const Duration(milliseconds: 320),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 280),
                          pageBuilder: (_, __, ___) =>
                              LeiReadingScreen(lei: leis[index]),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            final tween = Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).chain(
                              CurveTween(curve: Curves.easeOutCubic),
                            );
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              // Glassmorphism Overlay Line
              Positioned(
                bottom: 0,
                left: 10,
                right: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: overlayColor.withValues(alpha: 0.62),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
