import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../models/score.dart';
import '../data/data_repository.dart';

class TestController extends ChangeNotifier {
  final AppData data;

  int testVersion = 60;
  String language = 'ko';
  int currentIndex = 0;
  final Map<int, int> answers = {};

  TestController(this.data);

  void setVersion(int version) {
    testVersion = version;
    reset();
  }

  void setLanguage(String code) {
    language = code;
    notifyListeners();
  }

  int get maxTier {
    if (testVersion == 60) return 1;
    if (testVersion == 120) return 2;
    return 3;
  }

  List<Question> get questions {
    return data.questions.where((q) => q.tier <= maxTier).toList(growable: false);
  }

  Question get currentQuestion => questions[currentIndex];

  double get progress => (currentIndex + 1) / questions.length;

  bool get isComplete => answers.length == questions.length;

  int? getAnswer(int questionId) => answers[questionId];

  void setAnswer(int questionId, int value) {
    answers[questionId] = value;
    notifyListeners();
  }

  void next() {
    if (currentIndex < questions.length - 1) {
      currentIndex += 1;
      notifyListeners();
    }
  }

  void prev() {
    if (currentIndex > 0) {
      currentIndex -= 1;
      notifyListeners();
    }
  }

  Scores calculateScores() {
    double scoreForFactor(String factor) {
      final items = questions.where((q) => q.factor == factor).toList();
      double total = 0;
      int count = 0;
      for (final question in items) {
        final answer = answers[question.id];
        if (answer != null) {
          final value = question.reverse ? (6 - answer) : answer;
          total += value;
          count += 1;
        }
      }
      if (count == 0) return 50;
      final avg = total / count;
      final scaled = ((avg - 1) / 4) * 100;
      return double.parse(scaled.toStringAsFixed(1));
    }

    return Scores(
      h: scoreForFactor('H'),
      e: scoreForFactor('E'),
      x: scoreForFactor('X'),
      a: scoreForFactor('A'),
      c: scoreForFactor('C'),
      o: scoreForFactor('O'),
    );
  }

  void reset() {
    currentIndex = 0;
    answers.clear();
    notifyListeners();
  }
}
