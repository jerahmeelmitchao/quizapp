import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_folder.dart';
import '../../models/study_set.dart';
import '../../services/study_set_service.dart';
import 'create_flashcard_page.dart';
import 'flashcard_review_page.dart';

class FolderSetsPage extends StatefulWidget {
  final ThemeController themeController;
  final StudyFolder folder;

  const FolderSetsPage({
    super.key,
    required this.themeController,
    required this.folder,
  });

  @override
  State<FolderSetsPage> createState() => _FolderSetsPageState();
}

class _FolderSetsPageState extends State<FolderSetsPage> {
  List<StudySet> sets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await StudySetService.getAll();
    if (!mounted) return;
    setState(() {
      sets = all.where((s) => s.folderId == widget.folder.id).toList();
      isLoading = false;
    });
  }

  Future<void> _deleteSet(String id) async {
    await StudySetService.delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : sets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.style_rounded,
                            size: 60,
                            color: palette.textLight.withOpacity(0.3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No flashcard sets in this folder.',
                            style: TextStyle(
                              color: palette.textLight.withOpacity(0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go to Quick Actions → Create Flashcards\nand choose this folder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textLight.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: sets.length,
                      itemBuilder: (_, i) {
                        final set = sets[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FlashcardReviewPage(
                                      themeController: widget.themeController,
                                      studySet: set,
                                    ),
                                  ),
                                );
                                _load();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: palette.secondary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.style_rounded,
                                        color: palette.secondary,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            set.title,
                                            style: TextStyle(
                                              color: palette.textDark,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${set.flashcards.length} card${set.flashcards.length == 1 ? '' : 's'}',
                                            style: TextStyle(
                                              color: palette.muted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Edit button
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_rounded,
                                        color: palette.secondary,
                                      ),
                                      tooltip: 'Edit / Add cards',
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CreateFlashcardPage(
                                              themeController:
                                                  widget.themeController,
                                              folder: widget.folder,
                                              existingSet: set,
                                            ),
                                          ),
                                        );
                                        _load();
                                      },
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Delete set?'),
                                            content: Text(
                                              'Delete "${set.title}"? This cannot be undone.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(context, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          _deleteSet(set.id);
                                        }
                                      },
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: palette.muted,
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
      ),
    );
  }
}
