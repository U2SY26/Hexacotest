import 'package:shared_preferences/shared_preferences.dart';

/// 카드 뽑기 일일 횟수 관리
/// - 매일 3회 무료 뽑기 (보상형 광고)
/// - 공유하기 1회 → +1 추가 뽑기 (매일 최대 3회)
/// - 결과 페이지 첫 뽑기는 별도 (항상 무료, 카운트 안 함)
class CardDrawService {
  static const _keyDate = 'card_draw_date';
  static const _keyAdDraws = 'card_ad_draw_count';
  static const _keyShareBonus = 'card_share_bonus_count';

  static const int maxDailyAdDraws = 3;
  static const int maxDailyShareBonus = 3;

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<_DailyState> _getState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_keyDate) ?? '';
    final today = _today();

    if (savedDate != today) {
      // 새 날, 리셋
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyAdDraws, 0);
      await prefs.setInt(_keyShareBonus, 0);
      return const _DailyState(adDrawsUsed: 0, shareBonusUsed: 0);
    }

    return _DailyState(
      adDrawsUsed: prefs.getInt(_keyAdDraws) ?? 0,
      shareBonusUsed: prefs.getInt(_keyShareBonus) ?? 0,
    );
  }

  /// 남은 광고 뽑기 횟수 (기본 3 + 공유 보너스)
  static Future<int> getRemainingAdDraws() async {
    final state = await _getState();
    final totalAllowed = maxDailyAdDraws + state.shareBonusUsed;
    return (totalAllowed - state.adDrawsUsed).clamp(0, maxDailyAdDraws + maxDailyShareBonus);
  }

  /// 남은 공유 보너스 횟수
  static Future<int> getRemainingShareBonus() async {
    final state = await _getState();
    return (maxDailyShareBonus - state.shareBonusUsed).clamp(0, maxDailyShareBonus);
  }

  /// 전체 상태 가져오기
  static Future<CardDrawStatus> getStatus() async {
    final state = await _getState();
    final totalAllowed = maxDailyAdDraws + state.shareBonusUsed;
    final remaining = (totalAllowed - state.adDrawsUsed).clamp(0, maxDailyAdDraws + maxDailyShareBonus);
    final remainingShares = (maxDailyShareBonus - state.shareBonusUsed).clamp(0, maxDailyShareBonus);

    return CardDrawStatus(
      remainingDraws: remaining,
      remainingShares: remainingShares,
      adDrawsUsed: state.adDrawsUsed,
      shareBonusUsed: state.shareBonusUsed,
    );
  }

  /// 광고 뽑기 1회 사용
  static Future<bool> useAdDraw() async {
    final remaining = await getRemainingAdDraws();
    if (remaining <= 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    await prefs.setString(_keyDate, today);
    final current = prefs.getInt(_keyAdDraws) ?? 0;
    await prefs.setInt(_keyAdDraws, current + 1);
    return true;
  }

  /// 공유로 보너스 뽑기 +1 추가
  static Future<bool> addShareBonus() async {
    final remainingShares = await getRemainingShareBonus();
    if (remainingShares <= 0) return false;

    final prefs = await SharedPreferences.getInstance();
    final today = _today();
    await prefs.setString(_keyDate, today);
    final current = prefs.getInt(_keyShareBonus) ?? 0;
    await prefs.setInt(_keyShareBonus, current + 1);
    return true;
  }
}

class _DailyState {
  final int adDrawsUsed;
  final int shareBonusUsed;
  const _DailyState({required this.adDrawsUsed, required this.shareBonusUsed});
}

class CardDrawStatus {
  final int remainingDraws;
  final int remainingShares;
  final int adDrawsUsed;
  final int shareBonusUsed;

  const CardDrawStatus({
    required this.remainingDraws,
    required this.remainingShares,
    required this.adDrawsUsed,
    required this.shareBonusUsed,
  });

  bool get canDraw => remainingDraws > 0;
  bool get canShare => remainingShares > 0;
}
