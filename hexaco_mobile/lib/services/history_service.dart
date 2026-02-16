import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/result_history.dart';

class HistoryService {
  static const _key = 'hexaco_result_history';

  static Future<List<ResultHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => ResultHistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<void> save(ResultHistoryEntry entry, {int maxEntries = 10}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    final updated = [entry, ...list];
    final trimmed = updated.take(maxEntries).toList();
    await prefs.setString(_key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    final updated = list.where((e) => e.id != id).toList();
    await prefs.setString(_key, jsonEncode(updated.map((e) => e.toJson()).toList()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
