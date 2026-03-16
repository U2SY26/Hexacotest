import 'package:flutter/material.dart';

import '../services/counseling_timer_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/buttons.dart';

/// 법적 면책 동의 화면 (첫 사용시 1회)
class CounselingDisclaimerScreen extends StatefulWidget {
  final bool isKo;

  const CounselingDisclaimerScreen({super.key, required this.isKo});

  @override
  State<CounselingDisclaimerScreen> createState() =>
      _CounselingDisclaimerScreenState();
}

class _CounselingDisclaimerScreenState
    extends State<CounselingDisclaimerScreen> {
  bool _agreed = false;

  Future<void> _onAccept() async {
    await CounselingTimerService.acceptDisclaimer();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/counselor-select');
    }
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
          widget.isKo ? 'AI 심리상담 안내' : 'AI Counseling Notice',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Title
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purple500.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.purple500.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.psychology_alt,
                            size: 36,
                            color: AppColors.purple400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        widget.isKo
                            ? '시작하기 전에 알아주세요'
                            : 'Before we begin',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Disclaimer items
                    _DisclaimerItem(
                      icon: Icons.medical_information_outlined,
                      title: widget.isKo
                          ? '전문 상담을 대체하지 않습니다'
                          : 'Not a substitute for professional help',
                      description: widget.isKo
                          ? '본 서비스는 전문적인 심리상담이나 치료를 대체하지 않습니다. 심각한 정서적 어려움이 있다면 전문가에게 상담하세요.'
                          : 'This service does not replace professional counseling or therapy. If you have serious emotional difficulties, please consult a professional.',
                    ),
                    _DisclaimerItem(
                      icon: Icons.smart_toy_outlined,
                      title: widget.isKo
                          ? 'AI가 생성하는 응답입니다'
                          : 'Responses are AI-generated',
                      description: widget.isKo
                          ? 'AI가 생성하는 응답은 참고용이며, 의료적 또는 심리학적 진단이 아닙니다.'
                          : 'AI-generated responses are for reference only and do not constitute medical or psychological diagnosis.',
                    ),
                    _DisclaimerItem(
                      icon: Icons.delete_outline,
                      title: widget.isKo
                          ? '대화 내용은 저장되지 않습니다'
                          : 'Conversations are not saved',
                      description: widget.isKo
                          ? '대화 내용은 앱을 닫으면 모두 사라집니다. 개인정보가 서버에 저장되지 않습니다.'
                          : 'All conversations disappear when you close the app. No personal data is stored on our servers.',
                    ),
                    _DisclaimerItem(
                      icon: Icons.timer_outlined,
                      title: widget.isKo
                          ? '하루 사용 시간이 제한됩니다'
                          : 'Daily usage time is limited',
                      description: widget.isKo
                          ? '기본 5분이 제공되며, 광고 시청으로 추가 시간을 얻을 수 있습니다 (하루 최대 20분).'
                          : 'You get 5 minutes by default. Watch ads to extend your time (up to 20 minutes per day).',
                    ),
                    _DisclaimerItem(
                      icon: Icons.emergency_outlined,
                      title: widget.isKo
                          ? '위기 상황에서는 전문기관에 연락하세요'
                          : 'Contact professionals in crisis',
                      description: widget.isKo
                          ? '자살, 자해 등 위기 상황시 정신건강 위기상담전화 1577-0199 또는 자살예방 상담전화 1393으로 연락해주세요.'
                          : 'In crisis situations, please contact your local crisis hotline (988 in US, 116 123 in UK).',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Agree checkbox + Button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                border: Border(
                  top: BorderSide(color: AppColors.darkBorder),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: _agreed
                                ? AppColors.purple500
                                : Colors.transparent,
                            border: Border.all(
                              color: _agreed
                                  ? AppColors.purple500
                                  : AppColors.gray500,
                              width: 2,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.isKo
                                ? '위 내용을 모두 이해하고 동의합니다'
                                : 'I understand and agree to all of the above',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: _agreed ? _onAccept : null,
                      child: Text(
                        widget.isKo ? '시작하기' : 'Get Started',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _DisclaimerItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.darkCard,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Icon(icon, size: 20, color: AppColors.purple400),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
