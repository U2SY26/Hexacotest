import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/score.dart';

class AIFactorAnalysis {
  final String factor;
  final String overview;
  final List<String> strengths;
  final List<String> risks;
  final String growth;

  const AIFactorAnalysis({
    required this.factor,
    required this.overview,
    required this.strengths,
    required this.risks,
    required this.growth,
  });

  factory AIFactorAnalysis.fromJson(Map<String, dynamic> json) {
    return AIFactorAnalysis(
      factor: json['factor'] ?? '',
      overview: json['overview'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      risks: List<String>.from(json['risks'] ?? []),
      growth: json['growth'] ?? '',
    );
  }
}

class AIAnalysisResult {
  final String summary;
  final List<AIFactorAnalysis> factors;

  const AIAnalysisResult({
    required this.summary,
    required this.factors,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      summary: json['summary'] ?? '',
      factors: (json['factors'] as List<dynamic>?)
              ?.map((f) => AIFactorAnalysis.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class AIAnalysisService {
  static const String _apiUrl = 'https://hexacotest.vercel.app/api/analyze';

  static Future<AIAnalysisResult?> fetchAnalysis(Scores scores, {bool isKo = true}) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'scores': {
            'H': scores.h,
            'E': scores.e,
            'X': scores.x,
            'A': scores.a,
            'C': scores.c,
            'O': scores.o,
          },
          'language': isKo ? 'ko' : 'en',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AIAnalysisResult.fromJson(json);
      }
      debugPrint('AI analysis failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('AI analysis error: $e');
    }
    return null;
  }
}
