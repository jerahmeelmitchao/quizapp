import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class AppShell extends StatelessWidget {
  final ThemeController themeController;
  final Widget child;

  const AppShell({
    super.key,
    required this.themeController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Stack(
      children: [
        Container(color: palette.background),
        Positioned(
          top: -70,
          right: -30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: palette.backgroundAccent.withOpacity(0.22),
              borderRadius: BorderRadius.circular(140),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: palette.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
        SafeArea(child: child),
        Positioned(
          right: 18,
          bottom: 18,
          child: FloatingActionButton(
            backgroundColor: palette.secondary,
            foregroundColor: Colors.white,
            onPressed: themeController.nextTheme,
            child: const Icon(Icons.palette_rounded),
          ),
        ),
      ],
    );
  }
}