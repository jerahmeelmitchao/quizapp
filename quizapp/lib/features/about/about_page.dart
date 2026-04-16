import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';

class AboutPage extends StatelessWidget {
  final ThemeController themeController;

  const AboutPage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: AppShell(
        themeController: themeController,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: palette.secondary.withOpacity(0.15),
                      child: Icon(Icons.info_rounded, size: 38, color: palette.secondary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'QuizGen',
                      style: TextStyle(
                        color: palette.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Study smarter with folders, flashcards, quizzes, reviewer notes, and offline-friendly features.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.muted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer',
                      style: TextStyle(
                        color: palette.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: palette.primary.withOpacity(0.18),
                        child: Icon(Icons.person_rounded, color: palette.textDark),
                      ),
                      title: Text(
                        'Jerahmeel B. Mitchao',
                        style: TextStyle(
                          color: palette.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        'Flutter app developer',
                        style: TextStyle(color: palette.muted),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This app supports file-based quiz generation, flashcard folders, reviewer notes, smart multiple-choice quizzes, and exam mode for studying.',
                      style: TextStyle(color: palette.muted, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
