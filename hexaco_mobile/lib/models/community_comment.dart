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
