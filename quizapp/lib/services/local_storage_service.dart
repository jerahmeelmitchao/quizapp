import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/generation_record.dart';
import '../models/quiz.dart';

class LocalStorageService {
  static const String _recentGenerationsKey = 'recent_generations';

  static Future<List<GenerationRecord>> getRecentGenerations() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_recentGenerationsKey) ?? [];

    return rawList
        .map((item) => GenerationRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> saveGeneration({
    required String fileName,
    required Quiz quiz,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getRecentGenerations();

    final record = GenerationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      createdAt: DateTime.now(),
      quiz: quiz,
    );

    current.insert(0, record);

    final trimmed = current.take(20).toList();

    await prefs.setStringList(
      _recentGenerationsKey,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> updateGenerationScore({
    required String id,
    required int score,
    required int totalItems,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getRecentGenerations();

    final updated = current.map((record) {
      if (record.id == id) {
        return record.copyWith(
          lastScore: score,
          totalItems: totalItems,
        );
      }
      return record;
    }).toList();

    await prefs.setStringList(
      _recentGenerationsKey,
      updated.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<void> clearRecentGenerations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentGenerationsKey);
  }
}