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
    final myId = CommunityAuthService.myId;
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

    final myId = CommunityAuthService.myId;
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
