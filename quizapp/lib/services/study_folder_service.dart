import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_folder.dart';

class StudyFolderService {
  static const _key = 'study_folders';

  static Future<List<StudyFolder>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw.map((e) => StudyFolder.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> save(StudyFolder folder) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();

    current.add(folder);

    await prefs.setStringList(
      _key,
      current.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}