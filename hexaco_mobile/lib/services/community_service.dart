import 'package:cloud_firestore/cloud_firestore.dart';
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
    final myId = CommunityAuthService.myId;
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

    final myId = CommunityAuthService.myId;
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
      'authorId': user.uid,
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
    final myId = CommunityAuthService.myId;
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
      'authorId': user.uid,
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
    final myId = CommunityAuthService.myId!;
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
    final myId = CommunityAuthService.myId!;
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
    final myId = CommunityAuthService.myId!;
    await _posts.doc(postId).collection('reports').doc(myId).set({
      'reason': reason,
      'createdAt': Timestamp.now(),
    });
  }

  /// Report a comment
  static Future<void> reportComment(String postId, String commentId, {String? reason}) async {
    final myId = CommunityAuthService.myId!;
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
    final myId = CommunityAuthService.myId!;
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
