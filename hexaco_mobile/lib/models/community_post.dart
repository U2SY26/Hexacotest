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
