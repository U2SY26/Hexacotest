import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/community_user.dart';

class CommunityAuthService {
  static const String _nicknameKey = 'community_nickname';

  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static CommunityUser? _currentUser;

  /// Firebase Auth UID (document key for community_users)
  static String? get myId => _auth.currentUser?.uid;
  static CommunityUser? get currentUser => _currentUser;

  /// Initialize: anonymous auth + check if user exists
  static Future<bool> initialize({required String lang}) async {
    try {
      // Sign in anonymously if not already
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      final uid = _auth.currentUser!.uid;

      // Check if user exists in Firestore
      final userDoc = await _db.collection('community_users').doc(uid).get();

      if (userDoc.exists) {
        _currentUser = CommunityUser.fromFirestore(userDoc);
        return true;
      } else {
        // First time — need nickname setup
        return false;
      }
    } catch (e) {
      debugPrint('CommunityAuthService init failed: $e');
      return false;
    }
  }

  /// Create new community user with nickname
  static Future<CommunityUser> createUser({
    required String nickname,
    required String lang,
  }) async {
    // Ensure signed in
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();

    final user = CommunityUser(
      hashedDeviceId: uid,
      uid: uid,
      nickname: nickname,
      lang: lang,
      createdAt: now,
      updatedAt: now,
    );

    await _db.collection('community_users').doc(uid).set(user.toFirestore());

    // Save nickname locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);

    _currentUser = user;
    return user;
  }

  /// Update FCM token
  static Future<void> updateFcmToken(String token) async {
    final uid = myId;
    if (uid == null) return;
    await _db.collection('community_users').doc(uid).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Refresh current user data from Firestore
  static Future<void> refreshUser() async {
    final uid = myId;
    if (uid == null) return;
    final doc = await _db.collection('community_users').doc(uid).get();
    if (doc.exists) {
      _currentUser = CommunityUser.fromFirestore(doc);
    }
  }

  /// Generate a random nickname
  static String generateNickname() {
    const adjectives = [
      '용감한', '지혜로운', '따뜻한', '밝은', '고요한',
      '씩씩한', '다정한', '활발한', '차분한', '영리한',
      '행복한', '든든한', '기운찬', '상냥한', '당당한',
    ];
    const animals = [
      '코끼리', '고양이', '강아지', '토끼', '여우',
      '사슴', '팬더', '돌고래', '올빼미', '다람쥐',
      '펭귄', '햄스터', '코알라', '수달', '거북이',
    ];
    final adj = adjectives[(DateTime.now().microsecond) % adjectives.length];
    final animal = animals[(DateTime.now().millisecond) % animals.length];
    final num = (DateTime.now().second * 17 + DateTime.now().millisecond) % 100;
    return '$adj$animal$num';
  }
}
