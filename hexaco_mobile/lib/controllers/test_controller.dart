import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/question.dart';
import '../models/score.dart';
import '../data/data_repository.dart';

class TestController extends ChangeNotifier {
  final AppData data;
  final Random _random = Random();

  int testVersion = 60;
  String language = 'ko';
  int currentIndex = 0;
  final Map<int, int> answers = {};
  List<Question> _selectedQuestions = [];

  TestController(this.data) {
    _selectRandomQuestions();
  }

  void setVersion(int version) {
    testVersion = version;
    reset();
  }

  void setLanguage(String code) {
    language = code;
    notifyListeners();
  }

  // Number of questions per factor based on test version
  int get _questionsPerFactor {
    switch (testVersion) {
      case 60:
        return 10;
      case 120:
        return 20;
      case 180:
        return 30;
      default:
        return 10;
    }
  }

  // Randomly select questions from each factor
  void _selectRandomQuestions() {
    final factors = ['H', 'E', 'X', 'A', 'C', 'O'];
    final selected = <Question>[];

    for (final factor in factors) {
      final factorQuestions = data.questions
          .where((q) => q.factor == factor)
          .toList();

      // Shuffle and take the required number
      factorQuestions.shuffle(_random);
      selected.addAll(factorQuestions.take(_questionsPerFactor));
    }

    // Shuffle the final list so questions from different factors are mixed
    selected.shuffle(_random);
    _selectedQuestions = selected;
  }

  List<Question> get questions => _selectedQuestions;

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
          // answer is now 0-100 percentage directly
          // reverse: high score means low trait, so invert
          final value = question.reverse ? (100 - answer) : answer;
          total += value;
          count += 1;
        }
      }
      if (count == 0) return 50;
      final avg = total / count;
      return double.parse(avg.toStringAsFixed(1));
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
    _selectRandomQuestions();
    notifyListeners();
  }
}
