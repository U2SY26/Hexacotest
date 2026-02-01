import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';
import '../models/type_profile.dart';
import '../models/result_insight.dart';

class AppData {
  final List<Question> questions;
  final List<TypeProfile> types;
  final List<ResultInsight> insights;

  const AppData({
    required this.questions,
    required this.types,
    required this.insights,
  });

  ResultInsight? getInsightForFactor(String factor, double score) {
    return insights.where((i) => i.factor == factor && i.matchesScore(score)).firstOrNull;
  }
}

class DataRepository {
  static Future<AppData> load() async {
    final questionsRaw = await rootBundle.loadString('assets/data/questions.json');
    final typesRaw = await rootBundle.loadString('assets/data/types.json');
    final illustrationsRaw =
        await rootBundle.loadString('assets/data/question_illustrations.json');

    final questionsJson = jsonDecode(questionsRaw) as List<dynamic>;
    final typesJson = jsonDecode(typesRaw) as List<dynamic>;
    final illustrationsJson = jsonDecode(illustrationsRaw) as Map<String, dynamic>;
    final illustrationMap = illustrationsJson.map(
      (key, value) => MapEntry(int.parse(key), value as String),
    );

    final questions = questionsJson
        .map((item) {
          final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
          final id = map['id'] as int;
          final illustration = illustrationMap[id];
          if (illustration != null && illustration.isNotEmpty) {
            map['illustration'] = illustration;
          }
          return Question.fromJson(map);
        })
        .toList(growable: false);

    final types = typesJson
        .map((item) => TypeProfile.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    final insightsRaw = await rootBundle.loadString('assets/data/result_insights.json');
    final insightsJson = jsonDecode(insightsRaw) as List<dynamic>;
    final insights = insightsJson
        .map((item) => ResultInsight.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return AppData(questions: questions, types: types, insights: insights);
  }
}
