import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_folder.dart';
import '../../models/study_set.dart';
import '../../services/study_set_service.dart';

class CreateFlashcardPage extends StatefulWidget {
  final ThemeController themeController;
  final StudyFolder folder;
  final StudySet? existingSet; // null = create new, non-null = edit existing

  const CreateFlashcardPage({
    super.key,
    required this.themeController,
    required this.folder,
    this.existingSet,
  });

  @override
  State<CreateFlashcardPage> createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {
  final titleController = TextEditingController();
  final frontController = TextEditingController();
  final backController = TextEditingController();
  final frontFocus = FocusNode();

  List<Flashcard> cards = [];
  int? editingIndex;

  bool get isEditMode => widget.existingSet != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      titleController.text = widget.existingSet!.title;
      cards = List.from(widget.existingSet!.flashcards);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    frontController.dispose();
    backController.dispose();
    frontFocus.dispose();
    super.dispose();
  }

  void _addOrUpdateCard() {
    final front = frontController.text.trim();
    final back = backController.text.trim();
    if (front.isEmpty || back.isEmpty) return;

    setState(() {
      if (editingIndex != null) {
        cards[editingIndex!] = Flashcard(front: front, back: back);
        editingIndex = null;
      } else {
        cards.add(Flashcard(front: front, back: back));
      }
      frontController.clear();
      backController.clear();
    });

    frontFocus.requestFocus();
  }

  void _editCard(int index) {
    setState(() {
      editingIndex = index;
      frontController.text = cards[index].front;
      backController.text = cards[index].back;
    });
    frontFocus.requestFocus();
  }

  void _deleteCard(int index) {
    setState(() {
      if (editingIndex == index) {
        editingIndex = null;
        frontController.clear();
        backController.clear();
      } else if (editingIndex != null && editingIndex! > index) {
        editingIndex = editingIndex! - 1;
      }
      cards.removeAt(index);
    });
  }

  void _cancelEdit() {
    setState(() {
      editingIndex = null;
      frontController.clear();
      backController.clear();
    });
  }

  Future<void> _saveSet() async {
    if (titleController.text.trim().isEmpty) {
      _showSnack('Please enter a set title');
      return;
    }
    if (cards.isEmpty) {
      _showSnack('Please add at least one flashcard');
      return;
    }

    if (isEditMode) {
      final updated = StudySet(
        id: widget.existingSet!.id,
        title: titleController.text.trim(),
        folderId: widget.folder.id,
        createdAt: widget.existingSet!.createdAt,
        reviewerNotes: widget.existingSet!.reviewerNotes,
        flashcards: cards,
        questions: widget.existingSet!.questions,
      );
      await StudySetService.update(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashcard set updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updated);
      }
    } else {
      final set = StudySet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleController.text.trim(),
        folderId: widget.folder.id,
        createdAt: DateTime.now(),
        reviewerNotes: [],
        flashcards: cards,
        questions: [],
      );
      await StudySetService.save(set);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to "${widget.folder.name}"!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final isEditing = editingIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Flashcards' : 'Create Flashcards'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_rounded, size: 16, color: palette.primary),
                const SizedBox(width: 6),
                Text(
                  widget.folder.name,
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AppShell(
        themeController: widget.themeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Set title
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(
                      color: palette.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Set title (e.g., Chapter 1 Algebra)',
                      hintStyle: TextStyle(color: palette.muted),
                      border: InputBorder.none,
                      prefixIcon:
                          Icon(Icons.title_rounded, color: palette.secondary),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Input area
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEditing
                                ? Icons.edit_rounded
                                : Icons.add_card_rounded,
                            color: palette.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditing ? 'Edit Flashcard' : 'Add Flashcard',
                            style: TextStyle(
                              color: palette.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Front
                      Container(
                        decoration: BoxDecoration(
                          color: palette.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: palette.primary.withOpacity(0.25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: TextField(
                          controller: frontController,
                          focusNode: frontFocus,
                          maxLines: 2,
                          style: TextStyle(color: palette.textDark),
                          decoration: InputDecoration(
                            hintText: 'Front — question or fact',
                            hintStyle: TextStyle(color: palette.muted),
                            border: InputBorder.none,
                            labelText: 'FRONT',
                            labelStyle: TextStyle(
                              color: palette.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Back
                      Container(
                        decoration: BoxDecoration(
                          color: palette.secondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: palette.secondary.withOpacity(0.25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: TextField(
                          controller: backController,
                          maxLines: 2,
                          style: TextStyle(color: palette.textDark),
                          decoration: InputDecoration(
                            hintText: 'Back — answer or explanation',
                            hintStyle: TextStyle(color: palette.muted),
                            border: InputBorder.none,
                            labelText: 'BACK',
                            labelStyle: TextStyle(
                              color: palette.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          if (isEditing) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cancelEdit,
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 46)),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _addOrUpdateCard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.secondary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 46),
                              ),
                              icon: Icon(isEditing
                                  ? Icons.check_rounded
                                  : Icons.add),
                              label: Text(
                                  isEditing ? 'Update Card' : 'Add Card'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cards list
              if (cards.isNotEmpty) ...[
                Text(
                  '${cards.length} card${cards.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: palette.textLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(cards.length, (i) {
                  final card = cards[i];
                  final isCurrentEdit = editingIndex == i;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isCurrentEdit
                            ? BorderSide(color: palette.secondary, width: 2)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      palette.secondary.withOpacity(0.15),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: palette.secondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit_rounded,
                                      size: 18, color: palette.muted),
                                  onPressed: () => _editCard(i),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.delete_rounded,
                                      size: 18, color: Colors.redAccent),
                                  onPressed: () => _deleteCard(i),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: palette.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                card.front,
                                style: TextStyle(
                                    color: palette.textDark,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: palette.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                card.back,
                                style: TextStyle(color: palette.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saveSet,
                icon: const Icon(Icons.save_rounded),
                label: Text(isEditMode ? 'Save Changes' : 'Save Flashcard Set'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
