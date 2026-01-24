import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';
import '../models/type_profile.dart';

class AppData {
  final List<Question> questions;
  final List<TypeProfile> types;

  const AppData({
    required this.questions,
    required this.types,
  });
}

class DataRepository {
  static Future<AppData> load() async {
    final questionsRaw = await rootBundle.loadString('assets/data/questions.json');
    final typesRaw = await rootBundle.loadString('assets/data/types.json');

    final questionsJson = jsonDecode(questionsRaw) as List<dynamic>;
    final typesJson = jsonDecode(typesRaw) as List<dynamic>;

    final questions = questionsJson
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    final types = typesJson
        .map((item) => TypeProfile.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return AppData(questions: questions, types: types);
  }
}
