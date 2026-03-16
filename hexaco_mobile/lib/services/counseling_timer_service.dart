import 'package:shared_preferences/shared_preferences.dart';

import 'history_service.dart';

/// 일일 상담 시간 제한 관리
class CounselingTimerService {
  static const _keyPrefix = 'counseling_time_';
  static const _keyAdPrefix = 'counseling_ad_';
  static const _keyDisclaimer = 'counseling_disclaimer_accepted';
  static const int baseMinutes = 5;
  static const int bonusMinutes = 5;
  static const int maxAdWatches = 3;

  static String _todayKey(String prefix) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return '$prefix$today';
  }

  /// 오늘 사용한 초
  static Future<int> getUsedSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayKey(_keyPrefix)) ?? 0;
  }

  /// 사용 시간 추가
  static Future<void> addUsedSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey(_keyPrefix);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + seconds);
  }

  /// 오늘 광고 시청 횟수
  static Future<int> getAdWatchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_todayKey(_keyAdPrefix)) ?? 0;
  }

  /// 광고 시청 횟수 증가
  static Future<void> incrementAdWatch() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey(_keyAdPrefix);
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// 광고 추가 시청 가능 여부
  static Future<bool> canWatchAd() async {
    final count = await getAdWatchCount();
    return count < maxAdWatches;
  }

  /// 남은 시간 (초)
  static Future<int> getRemainingSeconds() async {
    final used = await getUsedSeconds();
    final adCount = await getAdWatchCount();
    final totalAllowed = (baseMinutes + bonusMinutes * adCount) * 60;
    return (totalAllowed - used).clamp(0, totalAllowed);
  }

  /// 면책 동의 여부
  static Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDisclaimer) ?? false;
  }

  /// 면책 동의 저장
  static Future<void> acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDisclaimer, true);
  }

  /// 최소 1회 성격검사 완료 여부
  static Future<bool> hasCompletedTest() async {
    final history = await HistoryService.load();
    return history.isNotEmpty;
  }
}
