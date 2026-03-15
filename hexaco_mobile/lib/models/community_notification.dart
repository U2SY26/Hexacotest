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
