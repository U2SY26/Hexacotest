import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

import '../models/counselor_persona.dart';
import '../models/score.dart';

/// 채팅 메시지
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

/// 멀티 LLM 상담 서비스
class CounselingLLMService {
  static const _vercelUrl = 'https://hexacotest.vercel.app/api/counsel';

  static GenerativeModel? _geminiModel;

  static GenerativeModel _getGeminiModel() {
    return _geminiModel ??= FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topP: 0.9,
        maxOutputTokens: 500,
      ),
    );
  }

  /// 메시지 전송 + 응답 수신
  static Future<String> sendMessage({
    required CounselorPersona counselor,
    required List<ChatMessage> history,
    required String userMessage,
    required Scores scores,
    required String languageCode,
  }) async {
    final scoresMap = {
      'H': scores.h, 'E': scores.e, 'X': scores.x,
      'A': scores.a, 'C': scores.c, 'O': scores.o,
    };

    final systemPrompt = CounselorPromptBuilder.build(
      persona: counselor,
      scores: scoresMap,
      languageCode: languageCode,
    );

    switch (counselor.backend) {
      case LLMBackend.gemini:
        return _sendGemini(systemPrompt, history, userMessage);
      case LLMBackend.openai:
      case LLMBackend.claude:
        return _sendVercel(
          counselor.backend == LLMBackend.openai ? 'openai' : 'claude',
          systemPrompt,
          history,
          userMessage,
        );
    }
  }

  /// Gemini (Firebase AI) 직접 호출
  static Future<String> _sendGemini(
    String systemPrompt,
    List<ChatMessage> history,
    String userMessage,
  ) async {
    try {
      final model = _getGeminiModel();

      // Build conversation contents
      final contents = <Content>[
        Content.text('$systemPrompt\n\n---\nConversation starts now.'),
      ];

      for (final msg in history) {
        if (msg.role == 'user') {
          contents.add(Content.text(msg.content));
        } else {
          contents.add(Content('model', [TextPart(msg.content)]));
        }
      }
      contents.add(Content.text(userMessage));

      final response = await model.generateContent(contents);
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        return text.trim();
      }
    } catch (e) {
      debugPrint('Gemini counseling error: $e');
    }

    // Fallback to Vercel with openai
    return _sendVercel('openai', systemPrompt, history, userMessage);
  }

  /// Vercel 프록시를 통한 OpenAI/Claude 호출
  static Future<String> _sendVercel(
    String model,
    String systemPrompt,
    List<ChatMessage> history,
    String userMessage,
  ) async {
    try {
      final messages = [
        ...history.map((m) => m.toJson()),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http
          .post(
            Uri.parse(_vercelUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'systemPrompt': systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['content'] as String?;
        if (content != null && content.isNotEmpty) {
          return content.trim();
        }
      }

      debugPrint('Vercel counsel error: ${response.statusCode} ${response.body}');
    } catch (e) {
      debugPrint('Vercel counsel fallback error: $e');
    }

    // Final fallback — Gemini direct if not already tried
    if (model != 'gemini') {
      try {
        return await _sendGemini(systemPrompt, history, userMessage);
      } catch (_) {}
    }

    return 'Sorry, a temporary issue occurred. Please try again shortly.';
  }
}
