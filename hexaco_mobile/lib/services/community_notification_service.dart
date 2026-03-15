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
    final myId = CommunityAuthService.myId;
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
    final myId = CommunityAuthService.myId;
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
    final myId = CommunityAuthService.myId;
    if (myId == null) return;

    await _db
        .collection('notifications').doc(myId)
        .collection('items').doc(notifId)
        .update({'isRead': true});
  }

  /// Mark all as read
  static Future<void> markAllAsRead() async {
    final myId = CommunityAuthService.myId;
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
    final myId = CommunityAuthService.myId;
    if (myId == null) return Stream.value(0);

    return _db
        .collection('notifications').doc(myId)
        .collection('items')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
