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
                          final navigator = Navigator.of(context);
                          if (!notif.isRead) {
                            await CommunityNotificationService.markAsRead(notif.id);
                          }
                          if (notif.postId != null && mounted) {
                            navigator.pushNamed('/community/post', arguments: notif.postId);
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
