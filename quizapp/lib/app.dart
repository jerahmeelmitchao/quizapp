import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/home/home_page.dart';

class QuizGenApp extends StatefulWidget {
  const QuizGenApp({super.key});

  @override
  State<QuizGenApp> createState() => _QuizGenAppState();
}

class _QuizGenAppState extends State<QuizGenApp> {
  final ThemeController themeController = ThemeController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuizGen',
          theme: AppTheme.buildTheme(themeController.palette),
          home: HomePage(themeController: themeController),
        );
      },
    );
  }
}