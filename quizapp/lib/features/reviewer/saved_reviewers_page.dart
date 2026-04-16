import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/generation_record.dart';
import '../../services/local_storage_service.dart';
import '../quiz_preview/quiz_preview_page.dart';

class SavedReviewersPage extends StatefulWidget {
  final ThemeController themeController;

  const SavedReviewersPage({
    super.key,
    required this.themeController,
  });

  @override
  State<SavedReviewersPage> createState() => _SavedReviewersPageState();
}

class _SavedReviewersPageState extends State<SavedReviewersPage> {
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
      appBar: AppBar(title: const Text('Saved Reviewers')),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? Center(
                      child: Text(
                        'No saved reviewers yet.',
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
                            leading: const Icon(Icons.menu_book_rounded),
                            title: Text(
                              item.quiz.title,
                              style: TextStyle(
                                color: palette.textDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              item.fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                                    initialTabIndex: 0,
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