import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/personality_card.dart';

/// 뽑은 카드 보관함 관리 (최대 100장)
class CardCollectionService {
  static const _key = 'hexaco_card_collection';
  static const int maxCards = 100;

  static Future<List<PersonalityCard>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => PersonalityCard.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static Future<void> save(PersonalityCard card) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    final updated = [card, ...list];
    final trimmed = updated.take(maxCards).toList();
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    final updated = list.where((e) => e.id != id).toList();
    await prefs.setString(
      _key,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<Map<CardRarity, int>> getStats() async {
    final list = await load();
    final stats = <CardRarity, int>{
      CardRarity.r: 0,
      CardRarity.sr: 0,
      CardRarity.ssr: 0,
      CardRarity.legend: 0,
    };
    for (final card in list) {
      stats[card.rarity] = (stats[card.rarity] ?? 0) + 1;
    }
    return stats;
  }
}
