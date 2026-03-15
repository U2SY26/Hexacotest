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
