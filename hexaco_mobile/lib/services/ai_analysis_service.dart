import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
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

class AICompatibleMBTI {
  final String mbti;
  final String reason;

  const AICompatibleMBTI({required this.mbti, required this.reason});

  factory AICompatibleMBTI.fromJson(Map<String, dynamic> json) {
    return AICompatibleMBTI(
      mbti: json['mbti'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class AICelebrityMatch {
  final String name;
  final String description;
  final int similarity;
  final String reason;

  const AICelebrityMatch({
    required this.name,
    required this.description,
    required this.similarity,
    required this.reason,
  });

  factory AICelebrityMatch.fromJson(Map<String, dynamic> json) {
    return AICelebrityMatch(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      similarity: (json['similarity'] as num?)?.toInt() ?? 80,
      reason: json['reason'] ?? '',
    );
  }
}

class AIAnalysisResult {
  final String summary;
  final List<AIFactorAnalysis> factors;
  final List<AICompatibleMBTI> compatibleMBTIs;
  final List<AICelebrityMatch> celebrityMatches;

  const AIAnalysisResult({
    required this.summary,
    required this.factors,
    this.compatibleMBTIs = const [],
    this.celebrityMatches = const [],
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      summary: json['summary'] ?? '',
      factors: (json['factors'] as List<dynamic>?)
              ?.map((f) => AIFactorAnalysis.fromJson(f))
              .toList() ??
          [],
      compatibleMBTIs: (json['compatibleMBTIs'] as List<dynamic>?)
              ?.map((m) => AICompatibleMBTI.fromJson(m))
              .toList() ??
          [],
      celebrityMatches: (json['celebrityMatches'] as List<dynamic>?)
              ?.map((c) => AICelebrityMatch.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class AIAnalysisService {
  static GenerativeModel? _model;
  static const _fallbackUrl = 'https://hexacotest.vercel.app/api/analyze';

  static GenerativeModel _getModel() {
    return _model ??= FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        maxOutputTokens: 3500,
        responseMimeType: 'application/json',
      ),
    );
  }

  static String _buildPrompt(Scores scores, bool isKo, {String? country}) {
    final includeCelebrities = !isKo && country != null;

    final schemaBase = '{"summary":"<warm 3-4 sentence personality portrait>", "factors":[{"factor":"H","overview":"<warm 4-5 sentence analysis>","strengths":["<encouraging phrase>","<encouraging phrase>","<encouraging phrase>"],"risks":["<gently framed challenge>","<gently framed challenge>"],"growth":"<2 kind, actionable suggestions>"}], "compatibleMBTIs":[{"mbti":"XXXX","reason":"<1 sentence why this type is compatible>"},{"mbti":"XXXX","reason":"<1 sentence why>"},{"mbti":"XXXX","reason":"<1 sentence why>"}]';
    final schema = includeCelebrities
        ? '$schemaBase, "celebrityMatches":[{"name":"<full name>","description":"<brief role/title>","similarity":<70-95>,"reason":"<1 sentence why personality matches>"}]}'
        : '$schemaBase}';

    final lines = [
      isKo
          ? '당신은 따뜻하고 공감 능력이 뛰어난 성격 심리학 전문가입니다. 마치 오랜 경험을 가진 심리상담사가 내담자에게 이야기하듯, 편안하고 다정한 말투로 분석해주세요.'
          : 'You are a warm, empathetic personality psychologist. Write as if you are a caring counselor speaking gently to a client, making them feel understood and valued.',
      '',
      isKo
          ? '말투 지침: 반말이 아닌 존댓말을 사용하세요. "~하시네요", "~이실 거예요", "~해보시는 건 어떨까요?" 같은 부드러운 표현을 쓰세요. 판단하지 말고, 있는 그대로의 모습을 긍정적으로 바라봐주세요. 단점도 따뜻하게 감싸안는 표현으로 전달하세요.'
          : 'Tone: Use warm, encouraging language. Say "you might find..." instead of "you lack...". Frame challenges as growth opportunities. Make the person feel seen and appreciated.',
      '',
      'Personality scores range from 0-100 across 6 dimensions (H, E, X, A, C, O). Analyze the unique combination holistically.',
      'Avoid clinical diagnoses and mental health claims.',
      '',
      'Return JSON only with this schema:',
      schema,
      '',
      'Requirements:',
      '- Include all six factors exactly once: H, E, X, A, C, O',
      '- summary: Paint a warm, holistic portrait that makes the person feel understood',
      '- overview: Explain each factor with empathy and insight (4-5 sentences)',
      '- strengths: 3 genuine strengths per factor, described encouragingly',
      '- risks: 2 challenges per factor, framed gently as areas for growth',
      '- growth: 2 kind, specific suggestions that feel like a friend\'s advice',
      '- compatibleMBTIs: Based on 6-factor scores, suggest exactly 3 MBTI types that would be most compatible. Estimate the user\'s own MBTI from scores (X→E/I, O→N/S, A→F/T, C→J/P) and pick 3 complementary types. Each reason should be warm and insightful.',
    ];

    if (includeCelebrities) {
      final region = country == 'international'
          ? 'globally recognized'
          : 'from $country or internationally recognized';
      lines.add(
        '- celebrityMatches: Suggest exactly 5 well-known public figures $region whose personality would closely match this 6-factor profile. Include actors, musicians, athletes, leaders, or entrepreneurs that most people would recognize. Each similarity score should realistically reflect how close their personality is (70-95 range).',
      );
    }

    lines.addAll([
      '',
      'Scores: H=${scores.h.toStringAsFixed(1)}, E=${scores.e.toStringAsFixed(1)}, X=${scores.x.toStringAsFixed(1)}, A=${scores.a.toStringAsFixed(1)}, C=${scores.c.toStringAsFixed(1)}, O=${scores.o.toStringAsFixed(1)}',
    ]);

    return lines.join('\n');
  }

  static String? _extractJson(String text) {
    final cleaned = text.replaceAll(RegExp(r'```json|```'), '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    return cleaned.substring(start, end + 1);
  }

  /// Firebase AI Logic으로 분석, 실패 시 Vercel API 폴백
  static Future<AIAnalysisResult?> fetchAnalysis(Scores scores,
      {bool isKo = true, String? country}) async {
    // 1차: Firebase AI Logic
    try {
      final prompt = _buildPrompt(scores, isKo, country: country);
      final response =
          await _getModel().generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        final jsonText = _extractJson(text);
        if (jsonText != null) {
          return AIAnalysisResult.fromJson(
              jsonDecode(jsonText) as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Firebase AI error: $e');
    }

    // 2차: Vercel API 폴백
    try {
      debugPrint('Falling back to Vercel API...');
      final body = <String, dynamic>{
        'scores': {
          'H': scores.h,
          'E': scores.e,
          'X': scores.x,
          'A': scores.a,
          'C': scores.c,
          'O': scores.o,
        },
        'language': isKo ? 'ko' : 'en',
      };
      if (country != null) body['country'] = country;

      final response = await http
          .post(
            Uri.parse(_fallbackUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AIAnalysisResult.fromJson(json);
      }
      debugPrint('Vercel API error: ${response.statusCode}');
    } catch (e) {
      debugPrint('Vercel API fallback error: $e');
    }

    return null;
  }
}
