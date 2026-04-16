import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_set.dart';

class StudySetService {
  static const _key = 'study_sets';

  static Future<List<StudySet>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    return raw
        .map((e) => StudySet.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> save(StudySet set) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();

    current.insert(0, set);

    await prefs.setStringList(
      _key,
      current.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> update(StudySet updatedSet) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();

    final updated = current.map((e) {
      return e.id == updatedSet.id ? updatedSet : e;
    }).toList();

    await prefs.setStringList(
      _key,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();

    final updated = current.where((e) => e.id != id).toList();

    await prefs.setStringList(
      _key,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }
}