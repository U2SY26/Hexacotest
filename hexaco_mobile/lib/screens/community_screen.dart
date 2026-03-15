import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_auth_service.dart';
import '../services/community_service.dart';
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
  bool _isInitialized = false;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAuth());
  }

  Future<void> _initAuth() async {
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final exists = await CommunityAuthService.initialize(lang: lang);

      if (!mounted) return;

      if (!exists) {
        // First time — go to nickname setup
        final result = await Navigator.pushNamed(context, '/community/setup');
        if (result == null && mounted) {
          Navigator.pop(context);
          return;
        }
      }

      setState(() => _isInitialized = true);
      _loadPosts();
    } catch (e) {
      debugPrint('Community auth init failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초기화 실패: $e')),
        );
        Navigator.pop(context);
      }
    }
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
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
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFA855F7)),
            )
          : RefreshIndicator(
        onRefresh: () => _loadPosts(refresh: true),
        child: _posts.isEmpty && !_isLoading
            ? const Center(
                child: Text(
                  '아직 게시글이 없습니다.\n첫 글을 작성해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: _posts.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPosts());
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: Color(0xFFA855F7),
                        ),
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
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: post.likeCount >= 5
                        ? const Color(0xFFF59E0B)
                        : Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: TextStyle(
                      color: post.likeCount >= 5
                          ? const Color(0xFFF59E0B)
                          : Colors.white38,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
