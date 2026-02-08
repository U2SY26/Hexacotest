import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
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
  static GenerativeModel? _model;

  static GenerativeModel _getModel() {
    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 2500,
        responseMimeType: 'application/json',
      ),
    );
  }

  static String _buildPrompt(Scores scores, bool isKo) {
    return [
      isKo
          ? '당신은 따뜻하고 공감 능력이 뛰어난 성격 심리학 전문가입니다. 마치 오랜 경험을 가진 심리상담사가 내담자에게 이야기하듯, 편안하고 다정한 말투로 분석해주세요.'
          : 'You are a warm, empathetic personality psychologist. Write as if you are a caring counselor speaking gently to a client, making them feel understood and valued.',
      '',
      isKo
          ? '말투 지침: 반말이 아닌 존댓말을 사용하세요. "~하시네요", "~이실 거예요", "~해보시는 건 어떨까요?" 같은 부드러운 표현을 쓰세요. 판단하지 말고, 있는 그대로의 모습을 긍정적으로 바라봐주세요. 단점도 따뜻하게 감싸안는 표현으로 전달하세요.'
          : 'Tone: Use warm, encouraging language. Say "you might find..." instead of "you lack...". Frame challenges as growth opportunities. Make the person feel seen and appreciated.',
      '',
      'HEXACO scores range from 0-100. Analyze the unique combination holistically.',
      'Avoid clinical diagnoses, mental health claims, and MBTI references.',
      '',
      'Return JSON only with this schema:',
      '{"summary":"<warm 3-4 sentence personality portrait>", "factors":[{"factor":"H","overview":"<warm 4-5 sentence analysis>","strengths":["<encouraging phrase>","<encouraging phrase>","<encouraging phrase>"],"risks":["<gently framed challenge>","<gently framed challenge>"],"growth":"<2 kind, actionable suggestions>"}]}',
      '',
      'Requirements:',
      '- Include all six factors exactly once: H, E, X, A, C, O',
      '- summary: Paint a warm, holistic portrait that makes the person feel understood',
      '- overview: Explain each factor with empathy and insight (4-5 sentences)',
      '- strengths: 3 genuine strengths per factor, described encouragingly',
      '- risks: 2 challenges per factor, framed gently as areas for growth',
      "- growth: 2 kind, specific suggestions that feel like a friend's advice",
      '',
      'Scores: H=${scores.h.toStringAsFixed(1)}, E=${scores.e.toStringAsFixed(1)}, X=${scores.x.toStringAsFixed(1)}, A=${scores.a.toStringAsFixed(1)}, C=${scores.c.toStringAsFixed(1)}, O=${scores.o.toStringAsFixed(1)}',
    ].join('\n');
  }

  static String? _extractJson(String text) {
    final cleaned = text.replaceAll(RegExp(r'```json|```'), '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return cleaned.substring(start, end + 1);
  }

  static Future<AIAnalysisResult?> fetchAnalysis(Scores scores,
      {bool isKo = true}) async {
    try {
      final prompt = _buildPrompt(scores, isKo);
      final response =
          await _getModel().generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text == null || text.isEmpty) {
        debugPrint('No response text from Gemini');
        return null;
      }

      final jsonText = _extractJson(text);
      if (jsonText == null) {
        debugPrint('Failed to extract JSON from response');
        return null;
      }

      return AIAnalysisResult.fromJson(
          jsonDecode(jsonText) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('AI analysis error: $e');
      return null;
    }
  }
}
