import 'dart:math';

/// 카드 레어도 (R → SR → SSR → LEGEND)
enum CardRarity { r, sr, ssr, legend }

/// 카드 테마 (배경 그라디언트)
class CardTheme {
  final String id;
  final List<int> gradientColors; // hex values
  final int accentColor;
  final int secondaryAccent;

  const CardTheme({
    required this.id,
    required this.gradientColors,
    required this.accentColor,
    this.secondaryAccent = 0xFFFFFFFF,
  });
}

const cardThemes = [
  CardTheme(id: 'aurora', gradientColors: [0xFF0F0C29, 0xFF302B63, 0xFF24243E], accentColor: 0xFF7C3AED, secondaryAccent: 0xFFC084FC),
  CardTheme(id: 'ember', gradientColors: [0xFF1A0505, 0xFF5C1010, 0xFF1A0505], accentColor: 0xFFEF4444, secondaryAccent: 0xFFFCA5A5),
  CardTheme(id: 'ocean', gradientColors: [0xFF051525, 0xFF0E3460, 0xFF051525], accentColor: 0xFF3B82F6, secondaryAccent: 0xFF93C5FD),
  CardTheme(id: 'forest', gradientColors: [0xFF051A0A, 0xFF0A3A1A, 0xFF051A0A], accentColor: 0xFF10B981, secondaryAccent: 0xFF6EE7B7),
  CardTheme(id: 'sunset', gradientColors: [0xFF1A0F02, 0xFF5C3010, 0xFF1A0F02], accentColor: 0xFFF59E0B, secondaryAccent: 0xFFFDE68A),
  CardTheme(id: 'cosmic', gradientColors: [0xFF120820, 0xFF2D1B4E, 0xFF120820], accentColor: 0xFF8B5CF6, secondaryAccent: 0xFFE879F9),
  CardTheme(id: 'cherry', gradientColors: [0xFF1A0515, 0xFF4A1035, 0xFF1A0515], accentColor: 0xFFEC4899, secondaryAccent: 0xFFF9A8D4),
  CardTheme(id: 'arctic', gradientColors: [0xFF051520, 0xFF103550, 0xFF051520], accentColor: 0xFF06B6D4, secondaryAccent: 0xFF67E8F9),
  CardTheme(id: 'nebula', gradientColors: [0xFF100318, 0xFF2D0850, 0xFF100318], accentColor: 0xFFA855F7, secondaryAccent: 0xFFD8B4FE),
  CardTheme(id: 'jade', gradientColors: [0xFF031510, 0xFF084030, 0xFF031510], accentColor: 0xFF059669, secondaryAccent: 0xFF34D399),
  CardTheme(id: 'golden', gradientColors: [0xFF151005, 0xFF4A3810, 0xFF151005], accentColor: 0xFFD97706, secondaryAccent: 0xFFFCD34D),
  CardTheme(id: 'royal', gradientColors: [0xFF0A0520, 0xFF1A1050, 0xFF0A0520], accentColor: 0xFF6366F1, secondaryAccent: 0xFFA5B4FC),
];

/// 레어도별 설정
class RarityConfig {
  final String label;
  final String labelKo;
  final String icon;
  final int borderColor;
  final int glowColor;
  final int badgeColor;
  final double glowIntensity;
  final int particleCount;

  const RarityConfig({
    required this.label,
    required this.labelKo,
    required this.icon,
    required this.borderColor,
    required this.glowColor,
    required this.badgeColor,
    required this.glowIntensity,
    required this.particleCount,
  });
}

const rarityConfigs = <CardRarity, RarityConfig>{
  CardRarity.r: RarityConfig(
    label: 'R', labelKo: 'R', icon: '🔷',
    borderColor: 0xFF94A3B8, glowColor: 0x4D94A3B8, badgeColor: 0x3394A3B8,
    glowIntensity: 0.3, particleCount: 0,
  ),
  CardRarity.sr: RarityConfig(
    label: 'SR', labelKo: 'SR', icon: '💎',
    borderColor: 0xFF3B82F6, glowColor: 0x663B82F6, badgeColor: 0x403B82F6,
    glowIntensity: 0.5, particleCount: 8,
  ),
  CardRarity.ssr: RarityConfig(
    label: 'SSR', labelKo: 'SSR', icon: '🌟',
    borderColor: 0xFFA855F7, glowColor: 0x99A855F7, badgeColor: 0x4DA855F7,
    glowIntensity: 0.7, particleCount: 16,
  ),
  CardRarity.legend: RarityConfig(
    label: 'LEGEND', labelKo: 'LEGEND', icon: '👑',
    borderColor: 0xFFFBBF24, glowColor: 0xCCFBBF24, badgeColor: 0x66FBBF24,
    glowIntensity: 1.0, particleCount: 30,
  ),
};

/// 성격 카드 데이터
class PersonalityCard {
  final String id;
  final DateTime createdAt;
  final CardRarity rarity;
  final CardTheme theme;
  final String cardNumber;
  final Map<String, double> scores;
  final String emoji;
  final String titleKo;
  final String titleEn;
  final String quoteEmoji;
  final String quoteKo;
  final String quoteEn;
  final String topMatchName;
  final int topMatchSimilarity;
  final String mbti;

  PersonalityCard({
    required this.id,
    required this.createdAt,
    required this.rarity,
    required this.theme,
    required this.cardNumber,
    required this.scores,
    required this.emoji,
    required this.titleKo,
    required this.titleEn,
    required this.quoteEmoji,
    required this.quoteKo,
    required this.quoteEn,
    required this.topMatchName,
    required this.topMatchSimilarity,
    required this.mbti,
  });
}

/// 레어도 결정 — 원신 스타일 확률
/// 기본: R 55%, SR 35%, SSR 8.5%, LEGEND 1.5%
/// 점수 편차가 클수록 확률 보너스
CardRarity determineRarity(Map<String, double> scores) {
  final values = scores.values.toList();
  final avg = values.reduce((a, b) => a + b) / values.length;
  final variance = values.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / values.length;
  final stdDev = sqrt(variance);
  final extremeCount = values.where((v) => v >= 90 || v <= 10).length;

  // 편차 보너스 (0~1.0)
  double bonus = 0;
  if (stdDev > 25 || extremeCount >= 3) {
    bonus = 1.0;
  } else if (stdDev > 18 || extremeCount >= 2) {
    bonus = 0.6;
  } else if (stdDev > 12 || extremeCount >= 1) {
    bonus = 0.3;
  }

  // 원신 스타일: LEGEND 1.5~3%, SSR 8.5~14%, SR 35~38%, R 나머지
  final legendRate = 1.5 + bonus * 1.5;   // 1.5% ~ 3%
  final ssrRate = 8.5 + bonus * 5.5;      // 8.5% ~ 14%
  final srRate = 35.0 + bonus * 3.0;      // 35% ~ 38%

  final rand = Random().nextDouble() * 100;

  if (rand < legendRate) return CardRarity.legend;
  if (rand < legendRate + ssrRate) return CardRarity.ssr;
  if (rand < legendRate + ssrRate + srRate) return CardRarity.sr;
  return CardRarity.r;
}

/// 랜덤 카드번호 생성
String generateCardNumber() {
  const chars = '0123456789ABCDEF';
  final rand = Random();
  final buffer = StringBuffer('#');
  for (var i = 0; i < 4; i++) {
    buffer.write(chars[rand.nextInt(chars.length)]);
  }
  return buffer.toString();
}

/// 카드 생성
PersonalityCard createCard({
  required Map<String, double> scores,
  required String emoji,
  required String titleKo,
  required String titleEn,
  required String quoteEmoji,
  required String quoteKo,
  required String quoteEn,
  required String topMatchName,
  required int topMatchSimilarity,
  required String mbti,
}) {
  final rand = Random();
  return PersonalityCard(
    id: 'card-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(9999)}',
    createdAt: DateTime.now(),
    rarity: determineRarity(scores),
    theme: cardThemes[rand.nextInt(cardThemes.length)],
    cardNumber: generateCardNumber(),
    scores: scores,
    emoji: emoji,
    titleKo: titleKo,
    titleEn: titleEn,
    quoteEmoji: quoteEmoji,
    quoteKo: quoteKo,
    quoteEn: quoteEn,
    topMatchName: topMatchName,
    topMatchSimilarity: topMatchSimilarity,
    mbti: mbti,
  );
}
