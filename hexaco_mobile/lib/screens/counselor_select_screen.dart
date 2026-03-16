import 'package:flutter/material.dart';

import '../models/counselor_persona.dart';
import '../services/counseling_timer_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/counselor_avatar.dart';

/// 상담사 선택 화면
class CounselorSelectScreen extends StatefulWidget {
  final bool isKo;

  const CounselorSelectScreen({super.key, required this.isKo});

  @override
  State<CounselorSelectScreen> createState() => _CounselorSelectScreenState();
}

class _CounselorSelectScreenState extends State<CounselorSelectScreen> {
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadRemainingTime();
  }

  Future<void> _loadRemainingTime() async {
    final remaining = await CounselingTimerService.getRemainingSeconds();
    if (mounted) {
      setState(() => _remainingSeconds = remaining);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _selectCounselor(CounselorPersona persona) {
    if (_remainingSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isKo
                ? '오늘 상담 시간이 모두 소진되었습니다. 내일 다시 만나요!'
                : 'Today\'s counseling time is used up. See you tomorrow!',
          ),
          backgroundColor: AppColors.orange500,
        ),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      '/counseling-chat',
      arguments: persona,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isKo ? '상담사 선택' : 'Choose Counselor',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isKo
                      ? '당신에게 맞는 상담사를 선택하세요'
                      : 'Choose a counselor that suits you',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: _remainingSeconds > 60
                            ? AppColors.emerald500
                            : AppColors.red500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _remainingSeconds > 60
                              ? AppColors.emerald500
                              : AppColors.red500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Counselor list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: counselorPersonas.length,
              itemBuilder: (context, index) {
                final persona = counselorPersonas[index];
                return _CounselorCard(
                  persona: persona,
                  isKo: widget.isKo,
                  onTap: () => _selectCounselor(persona),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CounselorCard extends StatelessWidget {
  final CounselorPersona persona;
  final bool isKo;
  final VoidCallback onTap;

  const _CounselorCard({
    required this.persona,
    required this.isKo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(persona.accentColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            CounselorMiniAvatar(persona: persona, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        persona.name(isKo),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          persona.title(isKo),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: accentColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    persona.description(isKo),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
