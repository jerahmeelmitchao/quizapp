import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/generation_record.dart';
import '../../services/local_storage_service.dart';
import '../quiz_preview/quiz_preview_page.dart';

class SavedFlashcardsPage extends StatefulWidget {
  final ThemeController themeController;

  const SavedFlashcardsPage({
    super.key,
    required this.themeController,
  });

  @override
  State<SavedFlashcardsPage> createState() => _SavedFlashcardsPageState();
}

class _SavedFlashcardsPageState extends State<SavedFlashcardsPage> {
  List<GenerationRecord> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await LocalStorageService.getRecentGenerations();
    if (!mounted) return;
    setState(() {
      records = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Flashcards')),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? Center(
                      child: Text(
                        'No saved flashcards yet.',
                        style: TextStyle(
                          color: palette.textLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final item = records[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.style_rounded),
                            title: Text(
                              item.quiz.title,
                              style: TextStyle(
                                color: palette.textDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${item.quiz.keyPoints.length} flashcards',
                            ),
                            trailing:
                                const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizPreviewPage(
                                    quiz: item.quiz,
                                    themeController: widget.themeController,
                                    generationId: item.id,
                                    initialTabIndex: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}