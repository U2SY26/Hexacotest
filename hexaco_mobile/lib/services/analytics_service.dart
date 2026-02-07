import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static late FirebaseAnalytics _analytics;
  static late FirebaseAnalyticsObserver _observer;

  static FirebaseAnalyticsObserver get observer => _observer;

  static void init() {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// 화면 조회 이벤트
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// 테스트 시작
  static Future<void> logTestStart({required String language}) async {
    await _analytics.logEvent(
      name: 'test_start',
      parameters: {'language': language},
    );
  }

  /// 테스트 완료
  static Future<void> logTestComplete({
    required String language,
    required String topMatchId,
    required int similarity,
    required Map<String, double> scores,
  }) async {
    await _analytics.logEvent(
      name: 'test_complete',
      parameters: {
        'language': language,
        'top_match_id': topMatchId,
        'similarity': similarity,
        'score_h': scores['H']?.round() ?? 0,
        'score_e': scores['E']?.round() ?? 0,
        'score_x': scores['X']?.round() ?? 0,
        'score_a': scores['A']?.round() ?? 0,
        'score_c': scores['C']?.round() ?? 0,
        'score_o': scores['O']?.round() ?? 0,
      },
    );
  }

  /// 결과 공유
  static Future<void> logShare({required String method}) async {
    await _analytics.logShare(
      contentType: 'result',
      itemId: 'hexaco_result',
      method: method,
    );
  }

  /// 인트로 비디오 시청
  static Future<void> logIntroVideoComplete() async {
    await _analytics.logEvent(name: 'intro_video_complete');
  }

  /// 앱 업데이트 다이얼로그 표시
  static Future<void> logUpdateDialogShown({required bool isForced}) async {
    await _analytics.logEvent(
      name: 'update_dialog_shown',
      parameters: {'is_forced': isForced},
    );
  }

  /// 앱 업데이트 클릭
  static Future<void> logUpdateClicked() async {
    await _analytics.logEvent(name: 'update_clicked');
  }
}
