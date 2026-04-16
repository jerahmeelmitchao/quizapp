import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_folder.dart';
import '../../services/study_folder_service.dart';
import 'create_flashcard_page.dart';
import 'folder_sets_page.dart';

enum FolderPickerMode { createFlashcards, reviewNotes }

class FolderPickerPage extends StatefulWidget {
  final ThemeController themeController;
  final FolderPickerMode mode;

  const FolderPickerPage({
    super.key,
    required this.themeController,
    required this.mode,
  });

  @override
  State<FolderPickerPage> createState() => _FolderPickerPageState();
}

class _FolderPickerPageState extends State<FolderPickerPage> {
  List<StudyFolder> folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StudyFolderService.getAll();
    if (!mounted) return;
    setState(() {
      folders = data;
      isLoading = false;
    });
  }

  Future<void> _createFolderDialog() async {
    final controller = TextEditingController();
    final palette = widget.themeController.palette;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Folder',
          style: TextStyle(
            color: palette.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Folder name',
            filled: true,
            fillColor: palette.border.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: palette.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size(90, 42),
            ),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final folder = StudyFolder(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                createdAt: DateTime.now(),
              );
              await StudyFolderService.save(folder);
              if (!mounted) return;
              Navigator.pop(context);
              await _load();

              // After creating, immediately navigate
              if (mounted) {
                _navigateToFolder(folder);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _navigateToFolder(StudyFolder folder) {
    if (widget.mode == FolderPickerMode.createFlashcards) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateFlashcardPage(
            themeController: widget.themeController,
            folder: folder,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FolderSetsPage(
            themeController: widget.themeController,
            folder: folder,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final isCreate = widget.mode == FolderPickerMode.createFlashcards;
    final title = isCreate ? 'Choose a Folder' : 'My Notes';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCreate
                    ? 'Where should your flashcards go?'
                    : 'Pick a folder to review',
                style: TextStyle(
                  color: palette.textLight,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),

              // Create new folder button
              GestureDetector(
                onTap: _createFolderDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: palette.secondary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: palette.secondary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: palette.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.create_new_folder_rounded,
                          color: palette.secondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Create New Folder',
                        style: TextStyle(
                          color: palette.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (folders.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open_rounded,
                          size: 56,
                          color: palette.textLight.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No folders yet.\nCreate one to get started!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.textLight.withOpacity(0.5),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: folders.length,
                    itemBuilder: (_, i) {
                      final folder = folders[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () => _navigateToFolder(folder),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color:
                                          palette.secondary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.folder_rounded,
                                      color: palette.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      folder.name,
                                      style: TextStyle(
                                        color: palette.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
