import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

class CommunityTranslationService {
  static GenerativeModel? _model;

  // In-memory cache: "content_hash:targetLang" -> translated text
  static final Map<String, String> _cache = {};

  static GenerativeModel get _getModel {
    _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
    );
    return _model!;
  }

  /// Translate text to target language
  static Future<String> translate(String text, {required String targetLang}) async {
    final cacheKey = '${text.hashCode}:$targetLang';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final prompt = '''Translate the following text to $targetLang.
Return ONLY the translated text, nothing else.
If the text is already in $targetLang, return it unchanged.

Text: $text''';

      final response = await _getModel.generateContent([Content.text(prompt)]);
      final translated = response.text?.trim() ?? text;

      _cache[cacheKey] = translated;
      return translated;
    } catch (e) {
      debugPrint('Translation failed: $e');
      return text; // Return original on failure
    }
  }

  /// Clear translation cache
  static void clearCache() => _cache.clear();
}
