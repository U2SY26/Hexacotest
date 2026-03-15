import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityUser {
  final String hashedDeviceId;
  final String uid;
  final String nickname;
  final int xp;
  final int level;
  final int reportCount;
  final int banCount;
  final DateTime? banUntil;
  final String? fcmToken;
  final String lang;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommunityUser({
    required this.hashedDeviceId,
    required this.uid,
    required this.nickname,
    this.xp = 0,
    this.level = 1,
    this.reportCount = 0,
    this.banCount = 0,
    this.banUntil,
    this.fcmToken,
    this.lang = 'ko',
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunityUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityUser(
      hashedDeviceId: doc.id,
      uid: data['uid'] ?? '',
      nickname: data['nickname'] ?? '',
      xp: data['xp'] ?? 0,
      level: data['level'] ?? 1,
      reportCount: data['reportCount'] ?? 0,
      banCount: data['banCount'] ?? 0,
      banUntil: (data['banUntil'] as Timestamp?)?.toDate(),
      fcmToken: data['fcmToken'],
      lang: data['lang'] ?? 'ko',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'hashedDeviceId': hashedDeviceId,
    'nickname': nickname,
    'xp': xp,
    'level': level,
    'reportCount': reportCount,
    'banCount': banCount,
    'banUntil': banUntil != null ? Timestamp.fromDate(banUntil!) : null,
    'fcmToken': fcmToken,
    'lang': lang,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  bool get isBanned =>
      banUntil != null && banUntil!.isAfter(DateTime.now()) ||
      banCount >= 3;

  /// Level from XP: each level needs 30*level XP. Cumulative = 15*level*(level-1)
  static int calculateLevel(int totalXp) {
    int level = 1;
    int cumulative = 0;
    while (true) {
      final needed = 30 * level;
      if (cumulative + needed > totalXp) break;
      cumulative += needed;
      level++;
    }
    return level;
  }

  int get xpToNextLevel {
    int cumulative = 0;
    for (int i = 1; i < level; i++) {
      cumulative += 30 * i;
    }
    final needed = 30 * level;
    return cumulative + needed - xp;
  }

  double get levelProgress {
    int cumulative = 0;
    for (int i = 1; i < level; i++) {
      cumulative += 30 * i;
    }
    final needed = 30 * level;
    if (needed == 0) return 0;
    return ((xp - cumulative) / needed).clamp(0.0, 1.0);
  }
}
