# Community Board Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an anonymous community bulletin board with leveling, moderation, translation, and push notifications to the Hexaco Mobile app.

**Architecture:** Firestore direct integration for real-time CRUD, Cloud Functions for server-side logic (moderation, XP, notifications, FCM push). Flutter client with new screens, services, models, and widgets. Leveling system adapted from 3dweb sister project.

**Tech Stack:** Flutter/Dart, Firebase (Firestore, Auth, Cloud Functions, FCM, AI), Perspective API, Rive animations

**Spec:** `docs/superpowers/specs/2026-03-15-community-board-design.md`

---

## Chunk 1: Foundation — Models, Auth, Firestore Setup

### Task 1: Flutter Dependencies

**Files:**
- Modify: `hexaco_mobile/pubspec.yaml`

- [ ] **Step 1: Add new dependencies to pubspec.yaml**

Add under `dependencies:`:
```yaml
  cloud_firestore: ^5.6.0
  firebase_auth: ^5.5.0
  firebase_messaging: ^15.2.0
  crypto: ^3.0.6
```

- [ ] **Step 2: Run flutter pub get**

Run: `cd hexaco_mobile && flutter pub get`
Expected: All dependencies resolve successfully.

- [ ] **Step 3: Commit**

```bash
git add hexaco_mobile/pubspec.yaml hexaco_mobile/pubspec.lock
git commit -m "feat(community): add Firestore, Auth, FCM, crypto dependencies"
```

---

### Task 2: Community User Model

**Files:**
- Create: `hexaco_mobile/lib/models/community_user.dart`

- [ ] **Step 1: Create CommunityUser model**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/models/community_user.dart
git commit -m "feat(community): add CommunityUser model with level calculation"
```

---

### Task 3: Post and Comment Models

**Files:**
- Create: `hexaco_mobile/lib/models/community_post.dart`
- Create: `hexaco_mobile/lib/models/community_comment.dart`
- Create: `hexaco_mobile/lib/models/community_notification.dart`

- [ ] **Step 1: Create CommunityPost model**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String nickname;
  final int level;
  final String title;
  final String content;
  final String lang;
  final int likeCount;
  final int commentCount;
  final bool isBlinded;
  final int reportCount;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Client-side state
  bool isLikedByMe;
  String? translatedTitle;
  String? translatedContent;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.nickname,
    required this.level,
    required this.title,
    required this.content,
    required this.lang,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isBlinded = false,
    this.reportCount = 0,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isLikedByMe = false,
    this.translatedTitle,
    this.translatedContent,
  });

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      nickname: data['nickname'] ?? '',
      level: data['level'] ?? 1,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      lang: data['lang'] ?? 'ko',
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      isBlinded: data['isBlinded'] ?? false,
      reportCount: data['reportCount'] ?? 0,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorId': authorId,
    'nickname': nickname,
    'level': level,
    'title': title,
    'content': content,
    'lang': lang,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'isBlinded': isBlinded,
    'reportCount': reportCount,
    'isEdited': isEdited,
    'isDeleted': isDeleted,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 2: Create CommunityComment model**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String nickname;
  final int level;
  final String content;
  final String lang;
  final String? parentCommentId;
  final int likeCount;
  final bool isBest;
  final bool isBlinded;
  final int reportCount;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool isLikedByMe;
  String? translatedContent;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.nickname,
    required this.level,
    required this.content,
    required this.lang,
    this.parentCommentId,
    this.likeCount = 0,
    this.isBest = false,
    this.isBlinded = false,
    this.reportCount = 0,
    this.isEdited = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isLikedByMe = false,
    this.translatedContent,
  });

  bool get isReply => parentCommentId != null;

  factory CommunityComment.fromFirestore(DocumentSnapshot doc, String postId) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityComment(
      id: doc.id,
      postId: postId,
      authorId: data['authorId'] ?? '',
      nickname: data['nickname'] ?? '',
      level: data['level'] ?? 1,
      content: data['content'] ?? '',
      lang: data['lang'] ?? 'ko',
      parentCommentId: data['parentCommentId'],
      likeCount: data['likeCount'] ?? 0,
      isBest: data['isBest'] ?? false,
      isBlinded: data['isBlinded'] ?? false,
      reportCount: data['reportCount'] ?? 0,
      isEdited: data['isEdited'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorId': authorId,
    'nickname': nickname,
    'level': level,
    'content': content,
    'lang': lang,
    'parentCommentId': parentCommentId,
    'likeCount': likeCount,
    'isBest': isBest,
    'isBlinded': isBlinded,
    'reportCount': reportCount,
    'isEdited': isEdited,
    'isDeleted': isDeleted,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

- [ ] **Step 3: Create CommunityNotification model**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { comment, reply, like, best, report, levelup }

class CommunityNotification {
  final String id;
  final NotificationType type;
  final String? postId;
  final String? commentId;
  final String fromNickname;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  CommunityNotification({
    required this.id,
    required this.type,
    this.postId,
    this.commentId,
    required this.fromNickname,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory CommunityNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityNotification(
      id: doc.id,
      type: NotificationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => NotificationType.comment,
      ),
      postId: data['postId'],
      commentId: data['commentId'],
      fromNickname: data['fromNickname'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add hexaco_mobile/lib/models/community_post.dart hexaco_mobile/lib/models/community_comment.dart hexaco_mobile/lib/models/community_notification.dart
git commit -m "feat(community): add Post, Comment, Notification models"
```

---

### Task 4: Community Auth Service

**Files:**
- Create: `hexaco_mobile/lib/services/community_auth_service.dart`

- [ ] **Step 1: Create auth service with device ID hashing and anonymous auth**

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/community_user.dart';

class CommunityAuthService {
  static const String _nicknameKey = 'community_nickname';
  static const String _deviceIdKey = 'community_device_id';

  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? _hashedDeviceId;
  static CommunityUser? _currentUser;

  static String? get hashedDeviceId => _hashedDeviceId;
  static CommunityUser? get currentUser => _currentUser;

  /// Hash device ID with SHA-256
  static String hashDeviceId(String rawId) {
    final bytes = utf8.encode(rawId);
    return sha256.convert(bytes).toString();
  }

  /// Initialize: anonymous auth + device ID mapping
  static Future<bool> initialize(String rawDeviceId, {required String lang}) async {
    try {
      _hashedDeviceId = hashDeviceId(rawDeviceId);

      // Sign in anonymously if not already
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      final uid = _auth.currentUser!.uid;

      // Check if user exists in Firestore
      final userDoc = await _db.collection('community_users').doc(_hashedDeviceId).get();

      if (userDoc.exists) {
        _currentUser = CommunityUser.fromFirestore(userDoc);
      } else {
        // First time — need nickname setup
        return false;
      }
      return true;
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
    final uid = _auth.currentUser!.uid;
    final now = DateTime.now();

    final user = CommunityUser(
      hashedDeviceId: _hashedDeviceId!,
      uid: uid,
      nickname: nickname,
      lang: lang,
      createdAt: now,
      updatedAt: now,
    );

    await _db.collection('community_users').doc(_hashedDeviceId).set(user.toFirestore());

    // Save nickname locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);

    _currentUser = user;
    return user;
  }

  /// Update FCM token
  static Future<void> updateFcmToken(String token) async {
    if (_hashedDeviceId == null) return;
    await _db.collection('community_users').doc(_hashedDeviceId).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Refresh current user data from Firestore
  static Future<void> refreshUser() async {
    if (_hashedDeviceId == null) return;
    final doc = await _db.collection('community_users').doc(_hashedDeviceId).get();
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
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/services/community_auth_service.dart
git commit -m "feat(community): add auth service with device ID hashing and anonymous auth"
```

---

## Chunk 2: Core Services — Posts, Comments, Likes, Reports

### Task 5: Community Service (CRUD)

**Files:**
- Create: `hexaco_mobile/lib/services/community_service.dart`

- [ ] **Step 1: Create community service with post/comment CRUD, likes, reports**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../models/community_comment.dart';
import '../models/community_user.dart';
import 'community_auth_service.dart';

class CommunityService {
  static final _db = FirebaseFirestore.instance;
  static final _posts = _db.collection('posts');

  // Rate limiting
  static DateTime? _lastPostTime;
  static DateTime? _lastCommentTime;

  // ─── Posts ───

  /// Fetch posts with cursor-based pagination
  static Future<List<CommunityPost>> fetchPosts({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _posts
        .where('isBlinded', isEqualTo: false)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final posts = snapshot.docs.map((doc) => CommunityPost.fromFirestore(doc)).toList();

    // Check if current user liked each post
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId != null) {
      await Future.wait(posts.map((post) async {
        final likeDoc = await _posts.doc(post.id).collection('likes').doc(myId).get();
        post.isLikedByMe = likeDoc.exists;
      }));
    }

    return posts;
  }

  /// Get single post by ID
  static Future<CommunityPost?> getPost(String postId) async {
    final doc = await _posts.doc(postId).get();
    if (!doc.exists) return null;
    final post = CommunityPost.fromFirestore(doc);

    final myId = CommunityAuthService.hashedDeviceId;
    if (myId != null) {
      final likeDoc = await _posts.doc(postId).collection('likes').doc(myId).get();
      post.isLikedByMe = likeDoc.exists;
    }
    return post;
  }

  /// Create a new post
  static Future<String> createPost({
    required String title,
    required String content,
    required String lang,
  }) async {
    // Rate limit check
    if (_lastPostTime != null &&
        DateTime.now().difference(_lastPostTime!) < const Duration(seconds: 30)) {
      throw Exception('Too fast. Please wait before posting again.');
    }

    final user = CommunityAuthService.currentUser!;
    if (user.isBanned) throw Exception('You are currently banned from posting.');

    final now = DateTime.now();
    final doc = await _posts.add({
      'authorId': user.hashedDeviceId,
      'nickname': user.nickname,
      'level': user.level,
      'title': title,
      'content': content,
      'lang': lang,
      'likeCount': 0,
      'commentCount': 0,
      'isBlinded': false,
      'reportCount': 0,
      'isEdited': false,
      'isDeleted': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    _lastPostTime = now;

    // Award XP (+10 for post)
    await _addXp(10);

    return doc.id;
  }

  /// Edit a post
  static Future<void> editPost(String postId, {String? title, String? content}) async {
    final updates = <String, dynamic>{
      'isEdited': true,
      'updatedAt': Timestamp.now(),
    };
    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;

    await _posts.doc(postId).update(updates);
  }

  /// Soft-delete a post
  static Future<void> deletePost(String postId) async {
    await _posts.doc(postId).update({
      'isDeleted': true,
      'updatedAt': Timestamp.now(),
    });
  }

  // ─── Comments ───

  /// Fetch comments for a post
  static Future<List<CommunityComment>> fetchComments(String postId) async {
    final snapshot = await _posts.doc(postId).collection('comments')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt')
        .get();

    final comments = snapshot.docs
        .map((doc) => CommunityComment.fromFirestore(doc, postId))
        .toList();

    // Sort: BEST first (by likeCount desc), then chronological
    comments.sort((a, b) {
      if (a.isBest && !b.isBest) return -1;
      if (!a.isBest && b.isBest) return 1;
      if (a.isBest && b.isBest) return b.likeCount.compareTo(a.likeCount);
      return a.createdAt.compareTo(b.createdAt);
    });

    // Check likes
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId != null) {
      await Future.wait(comments.map((c) async {
        final likeDoc = await _posts.doc(postId)
            .collection('comments').doc(c.id)
            .collection('likes').doc(myId).get();
        c.isLikedByMe = likeDoc.exists;
      }));
    }

    return comments;
  }

  /// Create a comment or reply
  static Future<String> createComment({
    required String postId,
    required String content,
    required String lang,
    String? parentCommentId,
  }) async {
    if (_lastCommentTime != null &&
        DateTime.now().difference(_lastCommentTime!) < const Duration(seconds: 10)) {
      throw Exception('Too fast. Please wait before commenting again.');
    }

    final user = CommunityAuthService.currentUser!;
    if (user.isBanned) throw Exception('You are currently banned from posting.');

    final now = DateTime.now();
    final doc = await _posts.doc(postId).collection('comments').add({
      'authorId': user.hashedDeviceId,
      'nickname': user.nickname,
      'level': user.level,
      'content': content,
      'lang': lang,
      'parentCommentId': parentCommentId,
      'likeCount': 0,
      'isBest': false,
      'isBlinded': false,
      'reportCount': 0,
      'isEdited': false,
      'isDeleted': false,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    _lastCommentTime = now;
    await _addXp(5);

    return doc.id;
  }

  /// Edit a comment
  static Future<void> editComment(String postId, String commentId, String content) async {
    await _posts.doc(postId).collection('comments').doc(commentId).update({
      'content': content,
      'isEdited': true,
      'updatedAt': Timestamp.now(),
    });
  }

  /// Soft-delete a comment
  static Future<void> deleteComment(String postId, String commentId) async {
    await _posts.doc(postId).collection('comments').doc(commentId).update({
      'isDeleted': true,
      'updatedAt': Timestamp.now(),
    });
  }

  // ─── Likes ───

  /// Toggle like on a post
  static Future<bool> togglePostLike(String postId) async {
    final myId = CommunityAuthService.hashedDeviceId!;
    final likeRef = _posts.doc(postId).collection('likes').doc(myId);
    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      await likeRef.delete();
      return false; // unliked
    } else {
      await likeRef.set({'createdAt': Timestamp.now()});
      return true; // liked
    }
  }

  /// Toggle like on a comment
  static Future<bool> toggleCommentLike(String postId, String commentId) async {
    final myId = CommunityAuthService.hashedDeviceId!;
    final likeRef = _posts.doc(postId)
        .collection('comments').doc(commentId)
        .collection('likes').doc(myId);
    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      await likeRef.delete();
      return false;
    } else {
      await likeRef.set({'createdAt': Timestamp.now()});
      return true;
    }
  }

  // ─── Reports ───

  /// Report a post
  static Future<void> reportPost(String postId, {String? reason}) async {
    final myId = CommunityAuthService.hashedDeviceId!;
    await _posts.doc(postId).collection('reports').doc(myId).set({
      'reason': reason,
      'createdAt': Timestamp.now(),
    });
  }

  /// Report a comment
  static Future<void> reportComment(String postId, String commentId, {String? reason}) async {
    final myId = CommunityAuthService.hashedDeviceId!;
    await _posts.doc(postId)
        .collection('comments').doc(commentId)
        .collection('reports').doc(myId)
        .set({
      'reason': reason,
      'createdAt': Timestamp.now(),
    });
  }

  // ─── XP ───

  static Future<bool> _addXp(int amount) async {
    final myId = CommunityAuthService.hashedDeviceId!;
    final userRef = _db.collection('community_users').doc(myId);

    return _db.runTransaction((tx) async {
      final doc = await tx.get(userRef);
      if (!doc.exists) return false;

      final data = doc.data()!;
      final oldXp = data['xp'] as int? ?? 0;
      final oldLevel = data['level'] as int? ?? 1;
      final newXp = (oldXp + amount).clamp(0, 999999);
      final newLevel = CommunityUser.calculateLevel(newXp);

      tx.update(userRef, {
        'xp': newXp,
        'level': newLevel,
        'updatedAt': Timestamp.now(),
      });

      await CommunityAuthService.refreshUser();
      return newLevel > oldLevel;
    });
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/services/community_service.dart
git commit -m "feat(community): add CommunityService with CRUD, likes, reports, XP"
```

---

### Task 6: Notification Service

**Files:**
- Create: `hexaco_mobile/lib/services/community_notification_service.dart`

- [ ] **Step 1: Create notification service for FCM + Firestore notifications**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/community_notification.dart';
import 'community_auth_service.dart';

class CommunityNotificationService {
  static final _db = FirebaseFirestore.instance;
  static final _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and save token
  static Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _messaging.getToken();
        if (token != null) {
          await CommunityAuthService.updateFcmToken(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          CommunityAuthService.updateFcmToken(newToken);
        });
      }
    } catch (e) {
      debugPrint('FCM init failed: $e');
    }
  }

  /// Fetch notifications for current user
  static Future<List<CommunityNotification>> fetchNotifications({int limit = 50}) async {
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId == null) return [];

    final snapshot = await _db
        .collection('notifications').doc(myId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CommunityNotification.fromFirestore(doc))
        .toList();
  }

  /// Get unread notification count
  static Future<int> getUnreadCount() async {
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId == null) return 0;

    final snapshot = await _db
        .collection('notifications').doc(myId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notifId) async {
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId == null) return;

    await _db
        .collection('notifications').doc(myId)
        .collection('items').doc(notifId)
        .update({'isRead': true});
  }

  /// Mark all as read
  static Future<void> markAllAsRead() async {
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId == null) return;

    final snapshot = await _db
        .collection('notifications').doc(myId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Listen to unread count changes (real-time)
  static Stream<int> unreadCountStream() {
    final myId = CommunityAuthService.hashedDeviceId;
    if (myId == null) return Stream.value(0);

    return _db
        .collection('notifications').doc(myId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/services/community_notification_service.dart
git commit -m "feat(community): add notification service with FCM and Firestore"
```

---

### Task 7: Translation Service

**Files:**
- Create: `hexaco_mobile/lib/services/community_translation_service.dart`

- [ ] **Step 1: Create translation service using Firebase AI (Gemini 2.5 Flash)**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/services/community_translation_service.dart
git commit -m "feat(community): add translation service using Gemini 2.5 Flash"
```

---

## Chunk 3: UI Widgets — Level Badge, Level-Up Overlay, Chat Bubble

### Task 8: Level Badge Widget

**Files:**
- Create: `hexaco_mobile/lib/widgets/level_badge.dart`

- [ ] **Step 1: Create level badge widget adapted from 3dweb**

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({super.key, required this.level, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final tier = _getTier(level);

    Widget badge = CustomPaint(
      size: Size(size, size),
      painter: _HexBadgePainter(tier.color),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    // Glow for level 10+
    if (level >= 10) {
      badge = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tier.color.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: badge,
      );
    }

    // Shimmer for level 50+
    if (level >= 50) {
      badge = _ShimmerWrap(color: tier.color, child: badge);
    }

    return badge;
  }

  static _Tier _getTier(int level) {
    if (level >= 50) return _Tier(const Color(0xFFF59E0B), 'Gold');
    if (level >= 20) return _Tier(const Color(0xFF8B5CF6), 'Purple');
    if (level >= 10) return _Tier(const Color(0xFF3B82F6), 'Blue');
    if (level >= 5) return _Tier(const Color(0xFF10B981), 'Green');
    return _Tier(const Color(0xFF9CA3AF), 'Gray');
  }
}

class _Tier {
  final Color color;
  final String name;
  const _Tier(this.color, this.name);
}

class _HexBadgePainter extends CustomPainter {
  final Color color;
  _HexBadgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShimmerWrap extends StatefulWidget {
  final Color color;
  final Widget child;
  const _ShimmerWrap({required this.color, required this.child});

  @override
  State<_ShimmerWrap> createState() => _ShimmerWrapState();
}

class _ShimmerWrapState extends State<_ShimmerWrap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + 0.08 * math.sin(_ctrl.value * 2 * math.pi);
        return Transform.scale(scale: scale, child: widget.child);
      },
    );
  }
}

/// Nickname with level badge inline
class NicknameWithBadge extends StatelessWidget {
  final String nickname;
  final int level;
  final double badgeSize;
  final TextStyle? textStyle;

  const NicknameWithBadge({
    super.key,
    required this.nickname,
    required this.level,
    this.badgeSize = 20,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LevelBadge(level: level, size: badgeSize),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            nickname,
            style: textStyle ?? const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Time ago helper
String timeAgo(DateTime dateTime, {bool isKo = true}) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 365) return isKo ? '${diff.inDays ~/ 365}년 전' : '${diff.inDays ~/ 365}y';
  if (diff.inDays > 30) return isKo ? '${diff.inDays ~/ 30}개월 전' : '${diff.inDays ~/ 30}mo';
  if (diff.inDays > 0) return isKo ? '${diff.inDays}일 전' : '${diff.inDays}d';
  if (diff.inHours > 0) return isKo ? '${diff.inHours}시간 전' : '${diff.inHours}h';
  if (diff.inMinutes > 0) return isKo ? '${diff.inMinutes}분 전' : '${diff.inMinutes}m';
  return isKo ? '방금' : 'now';
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/widgets/level_badge.dart
git commit -m "feat(community): add level badge widget with hex design and tier colors"
```

---

### Task 9: Level-Up Overlay

**Files:**
- Move: `E:\Hexacotest\22243-46463-level-up (1).riv` → `hexaco_mobile/assets/rive/level_up.riv`
- Create: `hexaco_mobile/lib/widgets/level_up_overlay.dart`

- [ ] **Step 1: Copy Rive asset**

```bash
cp "E:/Hexacotest/22243-46463-level-up (1).riv" "E:/Hexacotest/hexaco_mobile/assets/rive/level_up.riv"
```

- [ ] **Step 2: Add asset to pubspec.yaml**

Add under `flutter: assets:`:
```yaml
    - assets/rive/level_up.riv
```

- [ ] **Step 3: Create level-up overlay widget**

```dart
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LevelUpOverlay {
  static void show(
    BuildContext context, {
    required int level,
    required int currentXp,
    required int nextLevelXp,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (_) => _LevelUpDialog(
        level: level,
        currentXp: currentXp,
        nextLevelXp: nextLevelXp,
      ),
    );
  }
}

class _LevelUpDialog extends StatefulWidget {
  final int level;
  final int currentXp;
  final int nextLevelXp;

  const _LevelUpDialog({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog> {
  Artboard? _artboard;
  SMINumber? _levelInput;
  SMINumber? _currentXpInput;
  SMINumber? _nextLvlXpInput;
  SMITrigger? _replayTrigger;

  @override
  void initState() {
    super.initState();
    _loadRive();
    // Auto-close after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _loadRive() async {
    try {
      final data = await RiveFile.asset('assets/rive/level_up.riv');
      final artboard = data.mainArtboard.instance();

      final controller = StateMachineController.fromArtboard(artboard);
      if (controller != null) {
        artboard.addController(controller);
        for (final input in controller.inputs) {
          if (input.name == 'Level' && input is SMINumber) {
            _levelInput = input;
            input.value = widget.level.toDouble();
          } else if (input.name == 'currentXP' && input is SMINumber) {
            _currentXpInput = input;
            input.value = widget.currentXp.toDouble();
          } else if (input.name == 'nextlvlXP' && input is SMINumber) {
            _nextLvlXpInput = input;
            input.value = widget.nextLevelXp.toDouble();
          } else if (input.name == 'Replay' && input is SMITrigger) {
            _replayTrigger = input;
            input.fire();
          }
        }
      }

      if (mounted) setState(() => _artboard = artboard);
    } catch (e) {
      debugPrint('Failed to load level_up.riv: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: _artboard != null
                    ? Rive(artboard: _artboard!)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL UP!',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add hexaco_mobile/assets/rive/level_up.riv hexaco_mobile/lib/widgets/level_up_overlay.dart hexaco_mobile/pubspec.yaml
git commit -m "feat(community): add level-up Rive overlay with hexagon animation"
```

---

## Chunk 4: Screens — Community, Post Detail, Write, Notifications, Nickname

### Task 10: Nickname Setup Screen

**Files:**
- Create: `hexaco_mobile/lib/screens/nickname_setup_screen.dart`

- [ ] **Step 1: Create nickname setup screen**

```dart
import 'package:flutter/material.dart';
import '../services/community_auth_service.dart';

class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  late final TextEditingController _ctrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: CommunityAuthService.generateNickname());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _ctrl.text.trim();
    if (nickname.isEmpty || nickname.length > 20) return;

    setState(() => _isLoading = true);
    try {
      final isKo = Localizations.localeOf(context).languageCode == 'ko';
      await CommunityAuthService.createUser(
        nickname: nickname,
        lang: isKo ? 'ko' : 'en',
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/community');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('닉네임 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Color(0xFFA855F7)),
            const SizedBox(height: 24),
            const Text(
              '커뮤니티에서 사용할\n닉네임을 설정해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _ctrl,
              maxLength: 20,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA855F7)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFA855F7).withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA855F7)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFA855F7)),
                  onPressed: () {
                    _ctrl.text = CommunityAuthService.generateNickname();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA855F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('시작하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/screens/nickname_setup_screen.dart
git commit -m "feat(community): add nickname setup screen"
```

---

### Task 11: Community Screen (Post List)

**Files:**
- Create: `hexaco_mobile/lib/screens/community_screen.dart`

- [ ] **Step 1: Create community screen with post list, pagination, pull-to-refresh**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';
import '../services/community_auth_service.dart';
import '../services/community_notification_service.dart';
import '../widgets/level_badge.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<CommunityPost> _posts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      _lastDoc = null;
      _posts.clear();
      _hasMore = true;
    }

    setState(() => _isLoading = true);
    try {
      final newPosts = await CommunityService.fetchPosts(startAfter: _lastDoc);
      setState(() {
        _posts.addAll(newPosts);
        _hasMore = newPosts.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text('커뮤니티'),
        actions: [
          // Notification bell with unread badge
          StreamBuilder<int>(
            stream: CommunityNotificationService.unreadCountStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(refresh: true),
        child: _posts.isEmpty && !_isLoading
            ? const Center(
                child: Text('아직 게시글이 없습니다.\n첫 글을 작성해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
              )
            : ListView.builder(
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    _loadPosts();
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: Color(0xFFA855F7)),
                      ),
                    );
                  }
                  return _PostCard(
                    post: _posts[index],
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/community/post',
                        arguments: _posts[index].id,
                      );
                      _loadPosts(refresh: true);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFA855F7),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/community/write');
          if (result == true) _loadPosts(refresh: true);
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (post.isBlinded) {
      return Card(
        color: const Color(0xFF1A1A2E),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '블라인드 처리된 게시글입니다.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                children: [
                  NicknameWithBadge(nickname: post.nickname, level: post.level),
                  const Spacer(),
                  Text(
                    timeAgo(post.createdAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                post.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Content preview
              Text(
                post.content,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  Icon(Icons.thumb_up_outlined,
                      size: 16, color: post.likeCount >= 5 ? const Color(0xFFF59E0B) : Colors.white38),
                  const SizedBox(width: 4),
                  Text('${post.likeCount}',
                      style: TextStyle(
                        color: post.likeCount >= 5 ? const Color(0xFFF59E0B) : Colors.white38,
                        fontSize: 13,
                      )),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment_outlined, size: 16, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}',
                      style: const TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/screens/community_screen.dart
git commit -m "feat(community): add community screen with post list and pagination"
```

---

### Task 12: Post Detail Screen

**Files:**
- Create: `hexaco_mobile/lib/screens/post_detail_screen.dart`

- [ ] **Step 1: Create post detail screen with comments, likes, reports, translation**

```dart
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../models/community_comment.dart';
import '../services/community_service.dart';
import '../services/community_auth_service.dart';
import '../services/community_translation_service.dart';
import '../widgets/level_badge.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  CommunityPost? _post;
  List<CommunityComment> _comments = [];
  bool _isLoading = true;
  final _commentCtrl = TextEditingController();
  String? _replyToCommentId;
  String? _replyToNickname;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final post = await CommunityService.getPost(widget.postId);
    final comments = await CommunityService.fetchComments(widget.postId);
    setState(() {
      _post = post;
      _comments = comments;
      _isLoading = false;
    });
  }

  Future<void> _submitComment() async {
    final content = _commentCtrl.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final isKo = Localizations.localeOf(context).languageCode == 'ko';
      await CommunityService.createComment(
        postId: widget.postId,
        content: content,
        lang: isKo ? 'ko' : 'en',
        parentCommentId: _replyToCommentId,
      );
      _commentCtrl.clear();
      _replyToCommentId = null;
      _replyToNickname = null;
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _translatePost() async {
    if (_post == null) return;
    final deviceLang = Localizations.localeOf(context).languageCode;
    final title = await CommunityTranslationService.translate(_post!.title, targetLang: deviceLang);
    final content = await CommunityTranslationService.translate(_post!.content, targetLang: deviceLang);
    setState(() {
      _post!.translatedTitle = title;
      _post!.translatedContent = content;
    });
  }

  Future<void> _translateComment(CommunityComment comment) async {
    final deviceLang = Localizations.localeOf(context).languageCode;
    final translated = await CommunityTranslationService.translate(comment.content, targetLang: deviceLang);
    setState(() => comment.translatedContent = translated);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7))),
      );
    }

    if (_post == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A1A),
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(child: Text('게시글을 찾을 수 없습니다.', style: TextStyle(color: Colors.white54))),
      );
    }

    final post = _post!;
    final myId = CommunityAuthService.hashedDeviceId;
    final isMyPost = post.authorId == myId;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        actions: [
          if (isMyPost)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final result = await Navigator.pushNamed(
                    context, '/community/write',
                    arguments: post,
                  );
                  if (result == true) _load();
                } else if (value == 'delete') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('삭제', style: TextStyle(color: Colors.white)),
                      content: const Text('이 글을 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await CommunityService.deletePost(post.id);
                    if (mounted) Navigator.pop(context, true);
                  }
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('수정')),
                const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Post header
                  Row(
                    children: [
                      NicknameWithBadge(nickname: post.nickname, level: post.level),
                      const Spacer(),
                      Text(timeAgo(post.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    post.translatedTitle ?? post.title,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (post.isEdited)
                    const Text('(수정됨)', style: TextStyle(color: Colors.white30, fontSize: 12)),
                  const SizedBox(height: 12),
                  // Content
                  Text(
                    post.translatedContent ?? post.content,
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  // Action row
                  Row(
                    children: [
                      // Like
                      _ActionChip(
                        icon: post.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                        label: '${post.likeCount}',
                        isActive: post.isLikedByMe,
                        onTap: () async {
                          final liked = await CommunityService.togglePostLike(post.id);
                          setState(() {
                            post.isLikedByMe = liked;
                            // Optimistic UI — actual count updated on reload
                          });
                          _load();
                        },
                      ),
                      const SizedBox(width: 12),
                      // Translate
                      _ActionChip(
                        icon: Icons.translate,
                        label: '번역',
                        onTap: _translatePost,
                      ),
                      const Spacer(),
                      // Report
                      if (!isMyPost)
                        _ActionChip(
                          icon: Icons.flag_outlined,
                          label: '신고',
                          onTap: () async {
                            await CommunityService.reportPost(post.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('신고되었습니다.')),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 32),
                  // Comments
                  Text('댓글 ${_comments.length}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ..._buildCommentTree(),
                ],
              ),
            ),
          ),
          // Comment input
          _buildCommentInput(),
        ],
      ),
    );
  }

  List<Widget> _buildCommentTree() {
    final topLevel = _comments.where((c) => c.parentCommentId == null).toList();
    final widgets = <Widget>[];

    for (final comment in topLevel) {
      widgets.add(_buildCommentWidget(comment, isReply: false));
      final replies = _comments.where((c) => c.parentCommentId == comment.id).toList();
      for (final reply in replies) {
        widgets.add(_buildCommentWidget(reply, isReply: true));
      }
    }
    return widgets;
  }

  Widget _buildCommentWidget(CommunityComment comment, {required bool isReply}) {
    if (comment.isDeleted) {
      return Padding(
        padding: EdgeInsets.only(left: isReply ? 32 : 0, bottom: 8),
        child: const Text('삭제된 댓글입니다.', style: TextStyle(color: Colors.white24, fontSize: 13)),
      );
    }
    if (comment.isBlinded) {
      return Padding(
        padding: EdgeInsets.only(left: isReply ? 32 : 0, bottom: 8),
        child: const Text('블라인드 처리된 댓글입니다.', style: TextStyle(color: Colors.white24, fontSize: 13)),
      );
    }

    final myId = CommunityAuthService.hashedDeviceId;
    final isMine = comment.authorId == myId;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 32 : 0, bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: comment.isBest
              ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
              : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(10),
          border: comment.isBest
              ? Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (comment.isBest) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('BEST', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                ],
                NicknameWithBadge(nickname: comment.nickname, level: comment.level, badgeSize: 16),
                const Spacer(),
                Text(timeAgo(comment.createdAt), style: const TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.translatedContent ?? comment.content,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            if (comment.isEdited)
              const Text('(수정됨)', style: TextStyle(color: Colors.white24, fontSize: 11)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Like
                GestureDetector(
                  onTap: () async {
                    await CommunityService.toggleCommentLike(widget.postId, comment.id);
                    _load();
                  },
                  child: Row(
                    children: [
                      Icon(
                        comment.isLikedByMe ? Icons.thumb_up : Icons.thumb_up_outlined,
                        size: 14,
                        color: comment.isLikedByMe ? const Color(0xFFA855F7) : Colors.white30,
                      ),
                      const SizedBox(width: 4),
                      Text('${comment.likeCount}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Reply
                if (!isReply)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToCommentId = comment.id;
                        _replyToNickname = comment.nickname;
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.reply, size: 14, color: Colors.white30),
                        SizedBox(width: 4),
                        Text('답글', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(width: 16),
                // Translate
                GestureDetector(
                  onTap: () => _translateComment(comment),
                  child: const Icon(Icons.translate, size: 14, color: Colors.white30),
                ),
                const Spacer(),
                // Actions menu
                if (isMine)
                  PopupMenuButton<String>(
                    iconSize: 16,
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await CommunityService.deleteComment(widget.postId, comment.id);
                        _load();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      await CommunityService.reportComment(widget.postId, comment.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('신고되었습니다.')),
                        );
                      }
                    },
                    child: const Icon(Icons.flag_outlined, size: 14, color: Colors.white24),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_replyToNickname != null)
            Row(
              children: [
                Text('@$_replyToNickname 에게 답글',
                    style: const TextStyle(color: Color(0xFFA855F7), fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() {
                    _replyToCommentId = null;
                    _replyToNickname = null;
                  }),
                  child: const Icon(Icons.close, size: 16, color: Colors.white38),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  maxLength: 500,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0A0A1A),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSubmitting ? null : _submitComment,
                icon: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA855F7)))
                    : const Icon(Icons.send, color: Color(0xFFA855F7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA855F7).withValues(alpha: 0.2) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? const Color(0xFFA855F7) : Colors.white54),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(
              color: isActive ? const Color(0xFFA855F7) : Colors.white54,
              fontSize: 13,
            )),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/screens/post_detail_screen.dart
git commit -m "feat(community): add post detail screen with comments, likes, reports, translation"
```

---

### Task 13: Post Write/Edit Screen

**Files:**
- Create: `hexaco_mobile/lib/screens/post_write_screen.dart`

- [ ] **Step 1: Create post write/edit screen with profanity check placeholder**

```dart
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';

class PostWriteScreen extends StatefulWidget {
  final CommunityPost? editPost; // null for new post, set for edit
  const PostWriteScreen({super.key, this.editPost});

  @override
  State<PostWriteScreen> createState() => _PostWriteScreenState();
}

class _PostWriteScreenState extends State<PostWriteScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isSubmitting = false;

  bool get _isEditing => widget.editPost != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.editPost?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.editPost?.content ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_isEditing) {
        await CommunityService.editPost(
          widget.editPost!.id,
          title: title,
          content: content,
        );
      } else {
        final isKo = Localizations.localeOf(context).languageCode == 'ko';
        await CommunityService.createPost(
          title: title,
          content: content,
          lang: isKo ? 'ko' : 'en',
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: Text(_isEditing ? '글 수정' : '글 작성'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFA855F7)))
                : Text(
                    _isEditing ? '수정' : '등록',
                    style: const TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              maxLength: 100,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                counterStyle: TextStyle(color: Colors.white24),
              ),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLength: 2000,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                decoration: const InputDecoration(
                  hintText: '고민이나 이야기를 자유롭게 작성해주세요...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/screens/post_write_screen.dart
git commit -m "feat(community): add post write/edit screen"
```

---

### Task 14: Notification Screen

**Files:**
- Create: `hexaco_mobile/lib/screens/notification_screen.dart`

- [ ] **Step 1: Create notification screen**

```dart
import 'package:flutter/material.dart';
import '../models/community_notification.dart';
import '../services/community_notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<CommunityNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _notifications = await CommunityNotificationService.fetchNotifications();
    setState(() => _isLoading = false);
  }

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.comment => Icons.comment,
      NotificationType.reply => Icons.reply,
      NotificationType.like => Icons.thumb_up,
      NotificationType.best => Icons.star,
      NotificationType.report => Icons.flag,
      NotificationType.levelup => Icons.arrow_upward,
    };
  }

  Color _colorForType(NotificationType type) {
    return switch (type) {
      NotificationType.comment => const Color(0xFF3B82F6),
      NotificationType.reply => const Color(0xFF6366F1),
      NotificationType.like => const Color(0xFFA855F7),
      NotificationType.best => const Color(0xFFF59E0B),
      NotificationType.report => Colors.red,
      NotificationType.levelup => const Color(0xFF10B981),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: () async {
              await CommunityNotificationService.markAllAsRead();
              _load();
            },
            child: const Text('모두 읽음', style: TextStyle(color: Color(0xFFA855F7))),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)))
          : _notifications.isEmpty
              ? const Center(child: Text('알림이 없습니다.', style: TextStyle(color: Colors.white54)))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _colorForType(notif.type).withValues(alpha: 0.2),
                          child: Icon(_iconForType(notif.type), color: _colorForType(notif.type), size: 20),
                        ),
                        title: Text(
                          notif.message,
                          style: TextStyle(
                            color: notif.isRead ? Colors.white54 : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _timeAgo(notif.createdAt),
                          style: const TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                        tileColor: notif.isRead ? null : const Color(0xFFA855F7).withValues(alpha: 0.05),
                        onTap: () async {
                          if (!notif.isRead) {
                            await CommunityNotificationService.markAsRead(notif.id);
                          }
                          if (notif.postId != null && mounted) {
                            Navigator.pushNamed(context, '/community/post', arguments: notif.postId);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}일 전';
    if (diff.inHours > 0) return '${diff.inHours}시간 전';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 전';
    return '방금';
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add hexaco_mobile/lib/screens/notification_screen.dart
git commit -m "feat(community): add notification screen"
```

---

## Chunk 5: Integration — Routes, Home Screen, Device ID

### Task 15: Register Routes and Get Device ID

**Files:**
- Modify: `hexaco_mobile/lib/main.dart`
- Modify: `hexaco_mobile/lib/screens/home_screen.dart`
- Modify: `hexaco_mobile/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add `device_info_plus` to pubspec.yaml for getting device ID**

Add to `dependencies:`:
```yaml
  device_info_plus: ^11.3.0
```

Run: `cd hexaco_mobile && flutter pub get`

- [ ] **Step 2: Add community routes to main.dart**

Add imports at the top of `main.dart`:
```dart
import 'screens/community_screen.dart';
import 'screens/post_detail_screen.dart';
import 'screens/post_write_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/nickname_setup_screen.dart';
import 'models/community_post.dart';
```

Add routes to `MaterialApp.routes` or `onGenerateRoute`:
```dart
'/community': (context) => const CommunityScreen(),
'/community/setup': (context) => const NicknameSetupScreen(),
'/notifications': (context) => const NotificationScreen(),
```

Add `onGenerateRoute` for parameterized routes:
```dart
onGenerateRoute: (settings) {
  if (settings.name == '/community/post') {
    final postId = settings.arguments as String;
    return MaterialPageRoute(
      builder: (_) => PostDetailScreen(postId: postId),
    );
  }
  if (settings.name == '/community/write') {
    final editPost = settings.arguments as CommunityPost?;
    return MaterialPageRoute(
      builder: (_) => PostWriteScreen(editPost: editPost),
    );
  }
  return null;
},
```

- [ ] **Step 3: Add community entry point and notification bell to home_screen.dart**

Add to AppBar actions (left of settings gear):
```dart
// Notification bell icon
StreamBuilder<int>(
  stream: CommunityNotificationService.unreadCountStream(),
  builder: (context, snapshot) {
    final count = snapshot.data ?? 0;
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        if (count > 0)
          Positioned(
            right: 8, top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(count > 99 ? '99+' : '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
      ],
    );
  },
),
```

Add a "Community" card/button section on the home screen that navigates to `/community` with device ID initialization:
```dart
// Community entry button — initialize auth then navigate
onTap: () async {
  final deviceInfo = DeviceInfoPlugin();
  String rawDeviceId;
  if (Platform.isAndroid) {
    final android = await deviceInfo.androidInfo;
    rawDeviceId = android.id;
  } else {
    final ios = await deviceInfo.iosInfo;
    rawDeviceId = ios.identifierForVendor ?? 'unknown';
  }

  final isKo = /* current locale check */;
  final exists = await CommunityAuthService.initialize(rawDeviceId, lang: isKo ? 'ko' : 'en');
  if (exists) {
    Navigator.pushNamed(context, '/community');
  } else {
    Navigator.pushNamed(context, '/community/setup');
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add hexaco_mobile/lib/main.dart hexaco_mobile/lib/screens/home_screen.dart hexaco_mobile/pubspec.yaml hexaco_mobile/pubspec.lock
git commit -m "feat(community): integrate routes, device ID, notification bell, community entry"
```

---

## Chunk 6: Cloud Functions — Reports, Likes, Notifications, Content Filter

### Task 16: Initialize Cloud Functions Project

**Files:**
- Create: `hexaco_mobile/functions/package.json`
- Create: `hexaco_mobile/functions/tsconfig.json`
- Create: `hexaco_mobile/functions/src/index.ts`

- [ ] **Step 1: Initialize Firebase Functions project**

```bash
cd E:/Hexacotest/hexaco_mobile
mkdir -p functions/src
```

- [ ] **Step 2: Create package.json**

```json
{
  "name": "hexaco-community-functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions"
  },
  "engines": {
    "node": "20"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^13.0.0",
    "firebase-functions": "^6.3.0",
    "node-fetch": "^2.7.0"
  },
  "devDependencies": {
    "typescript": "^5.7.0"
  }
}
```

- [ ] **Step 3: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "target": "es2022",
    "esModuleInterop": true
  },
  "compileOnSave": true,
  "include": ["src"]
}
```

- [ ] **Step 4: Create main index.ts with all Cloud Functions**

```typescript
import * as admin from "firebase-admin";
import {onDocumentCreated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// ─── Helper: Add XP and check level-up ───

async function addXp(userId: string, amount: number): Promise<boolean> {
  const userRef = db.collection("community_users").doc(userId);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(userRef);
    if (!doc.exists) return false;

    const data = doc.data()!;
    const oldXp = (data.xp as number) || 0;
    const oldLevel = (data.level as number) || 1;
    const newXp = Math.max(0, oldXp + amount);
    const newLevel = calculateLevel(newXp);

    tx.update(userRef, {xp: newXp, level: newLevel, updatedAt: admin.firestore.FieldValue.serverTimestamp()});

    if (newLevel > oldLevel) {
      // Create level-up notification
      await createNotification(userId, {
        type: "levelup",
        fromNickname: "System",
        message: `레벨 ${newLevel} 달성! 축하합니다!`,
      });
      return true;
    }
    return false;
  });
}

function calculateLevel(totalXp: number): number {
  let level = 1;
  let cumulative = 0;
  while (true) {
    const needed = 30 * level;
    if (cumulative + needed > totalXp) break;
    cumulative += needed;
    level++;
  }
  return level;
}

// ─── Helper: Create notification + FCM push ───

async function createNotification(
  userId: string,
  data: {type: string; postId?: string; commentId?: string; fromNickname: string; message: string}
) {
  // Save to Firestore
  await db.collection("notifications").doc(userId).collection("items").add({
    ...data,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send FCM push
  try {
    const userDoc = await db.collection("community_users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (fcmToken) {
      await messaging.send({
        token: fcmToken,
        notification: {title: "Hexaco 커뮤니티", body: data.message},
        data: {type: data.type, postId: data.postId || "", commentId: data.commentId || ""},
      });
    }
  } catch (e) {
    console.error("FCM send failed:", e);
  }
}

// ─── Helper: Apply ban ───

async function applyBan(userId: string) {
  const userRef = db.collection("community_users").doc(userId);
  const doc = await userRef.get();
  if (!doc.exists) return;

  const banCount = ((doc.data()!.banCount as number) || 0) + 1;
  let banUntil: Date | null = null;

  if (banCount === 1) {
    banUntil = new Date(Date.now() + 24 * 60 * 60 * 1000); // 1 day
  } else if (banCount === 2) {
    banUntil = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000); // 3 days
  }
  // banCount >= 3: permanent (no banUntil needed, checked by client as banCount >= 3)

  await userRef.update({
    banCount,
    banUntil: banUntil ? admin.firestore.Timestamp.fromDate(banUntil) : null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ─── Post Report ───

export const onPostReport = onDocumentCreated(
  "posts/{postId}/reports/{reporterId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);

    const reportCount = (await postRef.collection("reports").count().get()).data().count;

    if (reportCount >= 3) {
      const postDoc = await postRef.get();
      const authorId = postDoc.data()?.authorId;

      await postRef.update({isBlinded: true, reportCount});
      await addXp(authorId, -30);
      await applyBan(authorId);

      await createNotification(authorId, {
        type: "report",
        postId,
        fromNickname: "System",
        message: "게시글이 신고로 인해 블라인드 처리되었습니다.",
      });
    } else {
      await postRef.update({reportCount});
    }
  }
);

// ─── Comment Report ───

export const onCommentReport = onDocumentCreated(
  "posts/{postId}/comments/{commentId}/reports/{reporterId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);

    const reportCount = (await commentRef.collection("reports").count().get()).data().count;

    if (reportCount >= 3) {
      const commentDoc = await commentRef.get();
      const authorId = commentDoc.data()?.authorId;

      await commentRef.update({isBlinded: true, reportCount});
      await addXp(authorId, -30);
      await applyBan(authorId);

      await createNotification(authorId, {
        type: "report",
        postId,
        commentId,
        fromNickname: "System",
        message: "댓글이 신고로 인해 블라인드 처리되었습니다.",
      });
    } else {
      await commentRef.update({reportCount});
    }
  }
);

// ─── Post Like ───

export const onPostLike = onDocumentCreated(
  "posts/{postId}/likes/{likerId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);

    const likeCount = (await postRef.collection("likes").count().get()).data().count;
    await postRef.update({likeCount});

    const postDoc = await postRef.get();
    const authorId = postDoc.data()?.authorId;
    const likerId = event.params.likerId;

    if (authorId && authorId !== likerId) {
      await addXp(authorId, 3);

      const likerDoc = await db.collection("community_users").doc(likerId).get();
      const likerNickname = likerDoc.data()?.nickname || "누군가";

      await createNotification(authorId, {
        type: "like",
        postId,
        fromNickname: likerNickname,
        message: `${likerNickname}님이 회원님의 글을 좋아합니다.`,
      });
    }
  }
);

// ─── Post Unlike ───

export const onPostUnlike = onDocumentDeleted(
  "posts/{postId}/likes/{likerId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);
    const likeCount = (await postRef.collection("likes").count().get()).data().count;
    await postRef.update({likeCount});
  }
);

// ─── Comment Like ───

export const onCommentLike = onDocumentCreated(
  "posts/{postId}/comments/{commentId}/likes/{likerId}",
  async (event) => {
    const {postId, commentId, likerId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);

    const likeCount = (await commentRef.collection("likes").count().get()).data().count;
    await commentRef.update({likeCount});

    const commentDoc = await commentRef.get();
    const authorId = commentDoc.data()?.authorId;

    if (authorId && authorId !== likerId) {
      await addXp(authorId, 3);

      const likerDoc = await db.collection("community_users").doc(likerId).get();
      const likerNickname = likerDoc.data()?.nickname || "누군가";

      await createNotification(authorId, {
        type: "like",
        postId,
        commentId,
        fromNickname: likerNickname,
        message: `${likerNickname}님이 회원님의 댓글을 좋아합니다.`,
      });
    }

    // BEST check
    if (likeCount >= 5) {
      const wasBest = commentDoc.data()?.isBest || false;
      if (!wasBest) {
        await commentRef.update({isBest: true});
        await addXp(authorId, 20);

        await createNotification(authorId, {
          type: "best",
          postId,
          commentId,
          fromNickname: "System",
          message: "회원님의 댓글이 BEST로 선정되었습니다! (+20 XP)",
        });
      }
    }
  }
);

// ─── Comment Unlike ───

export const onCommentUnlike = onDocumentDeleted(
  "posts/{postId}/comments/{commentId}/likes/{likerId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);
    const likeCount = (await commentRef.collection("likes").count().get()).data().count;
    await commentRef.update({likeCount});
  }
);

// ─── New Comment ───

export const onNewComment = onDocumentCreated(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const data = event.data?.data();
    if (!data) return;

    const postRef = db.collection("posts").doc(postId);

    // Increment post comment count
    const commentCount = (await postRef.collection("comments")
      .where("isDeleted", "==", false).count().get()).data().count;
    await postRef.update({commentCount});

    // Award XP to commenter
    await addXp(data.authorId, 5);

    // Notify
    const parentCommentId = data.parentCommentId;
    if (parentCommentId) {
      // Reply — notify parent comment author
      const parentDoc = await postRef.collection("comments").doc(parentCommentId).get();
      const parentAuthorId = parentDoc.data()?.authorId;
      if (parentAuthorId && parentAuthorId !== data.authorId) {
        await createNotification(parentAuthorId, {
          type: "reply",
          postId,
          commentId,
          fromNickname: data.nickname,
          message: `${data.nickname}님이 회원님의 댓글에 답글을 달았습니다.`,
        });
      }
    } else {
      // Top-level comment — notify post author
      const postDoc = await postRef.get();
      const postAuthorId = postDoc.data()?.authorId;
      if (postAuthorId && postAuthorId !== data.authorId) {
        await createNotification(postAuthorId, {
          type: "comment",
          postId,
          commentId,
          fromNickname: data.nickname,
          message: `${data.nickname}님이 회원님의 글에 댓글을 달았습니다.`,
        });
      }
    }
  }
);

// ─── Content Filter (HTTPS Callable) ───

export const filterContent = onCall(async (request) => {
  const {text} = request.data;
  if (!text || typeof text !== "string") {
    throw new HttpsError("invalid-argument", "text is required");
  }

  // 1. Perspective API check
  const perspectiveApiKey = process.env.PERSPECTIVE_API_KEY;
  if (perspectiveApiKey) {
    try {
      const fetch = require("node-fetch");
      const response = await fetch(
        `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${perspectiveApiKey}`,
        {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({
            comment: {text},
            languages: ["ko", "en", "ja", "zh"],
            requestedAttributes: {
              TOXICITY: {},
              PROFANITY: {},
              THREAT: {},
            },
          }),
        }
      );
      const result = await response.json();
      const toxicity = result.attributeScores?.TOXICITY?.summaryScore?.value || 0;
      const profanity = result.attributeScores?.PROFANITY?.summaryScore?.value || 0;
      const threat = result.attributeScores?.THREAT?.summaryScore?.value || 0;

      if (toxicity >= 0.85 || profanity >= 0.90 || threat >= 0.85) {
        return {allowed: false, reason: "inappropriate_content"};
      }

      // Borderline — could add Gemini 2nd pass here
      if (toxicity >= 0.60) {
        // TODO: Gemini 2.5 Flash 2nd pass for borderline content
        // For now, allow borderline content
      }
    } catch (e) {
      console.error("Perspective API error:", e);
      // Allow on API failure (fail open)
    }
  }

  return {allowed: true};
});
```

- [ ] **Step 5: Install dependencies and build**

```bash
cd E:/Hexacotest/hexaco_mobile/functions
npm install
npm run build
```

- [ ] **Step 6: Commit**

```bash
git add hexaco_mobile/functions/
git commit -m "feat(community): add Cloud Functions for reports, likes, notifications, content filter"
```

---

## Chunk 7: Firestore Security Rules and Indexes

### Task 17: Firestore Rules and Indexes

**Files:**
- Create: `hexaco_mobile/firestore.rules`
- Create: `hexaco_mobile/firestore.indexes.json`

- [ ] **Step 1: Create Firestore security rules**

Write the full rules from the spec (Section 14) to `hexaco_mobile/firestore.rules`.

- [ ] **Step 2: Create composite indexes**

```json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isBlinded", "order": "ASCENDING"},
        {"fieldPath": "isDeleted", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "items",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "isRead", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ],
  "fieldOverrides": []
}
```

- [ ] **Step 3: Commit**

```bash
git add hexaco_mobile/firestore.rules hexaco_mobile/firestore.indexes.json
git commit -m "feat(community): add Firestore security rules and composite indexes"
```

---

## Task Dependencies (Parallelization Guide)

```
Task 1 (deps) ─────────────────────────┐
Task 2 (user model) ───┐               │
Task 3 (post/comment)  ├─> Task 5 (service) ──> Task 15 (integration)
Task 4 (auth service) ─┘               │
                                        │
Task 8 (badge widget) ─────────────────>│
Task 9 (level-up overlay) ─────────────>│
                                        │
Task 6 (notif service) ────────────────>│
Task 7 (translation) ─────────────────>│
                                        │
Task 10 (nickname screen) ────────────>│
Task 11 (community screen) ───────────>│
Task 12 (post detail screen) ─────────>│
Task 13 (post write screen) ──────────>│
Task 14 (notif screen) ───────────────>│
                                        │
Task 16 (cloud functions) ── independent
Task 17 (firestore rules) ── independent
```

**Parallel groups:**
- **Group A** (Flutter foundation): Tasks 1→2,3,4→5→15
- **Group B** (Widgets): Tasks 8, 9 (independent)
- **Group C** (Services): Tasks 6, 7 (independent)
- **Group D** (Screens): Tasks 10, 11, 12, 13, 14 (depend on models/services)
- **Group E** (Backend): Tasks 16, 17 (fully independent, can run in parallel with all)
