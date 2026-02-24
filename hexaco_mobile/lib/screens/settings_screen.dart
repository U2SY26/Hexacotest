import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/test_controller.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dark_card.dart';

class SettingsScreen extends StatefulWidget {
  final TestController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isClearing = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isClearing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        final isKo = widget.controller.language == 'ko';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKo ? '캐시가 삭제되었습니다.' : 'Cache cleared.'),
            backgroundColor: AppColors.emerald500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isKo = widget.controller.language == 'ko';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isKo ? '캐시 삭제 실패' : 'Failed to clear cache'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isKo = widget.controller.language == 'ko';

        return AppScaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isKo ? '설정' : 'Settings',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              _SectionTitle(title: isKo ? '언어 설정' : 'Language'),
              const SizedBox(height: 12),
              DarkCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.language,
                      iconColor: AppColors.blue500,
                      title: '한국어',
                      trailing: widget.controller.language == 'ko'
                          ? const Icon(Icons.check_circle, color: AppColors.purple500, size: 24)
                          : const Icon(Icons.circle_outlined, color: AppColors.gray500, size: 24),
                      onTap: () => widget.controller.setLanguage('ko'),
                    ),
                    const Divider(color: AppColors.darkBorder, height: 1),
                    _SettingsTile(
                      icon: Icons.language,
                      iconColor: AppColors.blue500,
                      title: 'English',
                      trailing: widget.controller.language == 'en'
                          ? const Icon(Icons.check_circle, color: AppColors.purple500, size: 24)
                          : const Icon(Icons.circle_outlined, color: AppColors.gray500, size: 24),
                      onTap: () => widget.controller.setLanguage('en'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Data Section
              _SectionTitle(title: isKo ? '데이터 관리' : 'Data Management'),
              const SizedBox(height: 12),
              DarkCard(
                padding: const EdgeInsets.all(4),
                child: _SettingsTile(
                  icon: Icons.delete_outline,
                  iconColor: AppColors.orange500,
                  title: isKo ? '캐시 삭제' : 'Clear Cache',
                  subtitle: isKo ? '테스트 기록 및 설정 초기화' : 'Reset test history and settings',
                  trailing: _isClearing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.purple500,
                          ),
                        )
                      : const Icon(Icons.chevron_right, color: AppColors.gray500),
                  onTap: _isClearing ? null : _clearCache,
                ),
              ),

              const SizedBox(height: 24),

              // Support Section
              _SectionTitle(title: isKo ? '후원하기' : 'Support'),
              const SizedBox(height: 12),
              DarkCard(
                padding: const EdgeInsets.all(4),
                child: _SettingsTile(
                  icon: Icons.coffee,
                  iconColor: AppColors.amber500,
                  title: isKo ? 'PayPal로 후원하기' : 'Donate via PayPal',
                  subtitle: isKo ? '개발자에게 커피 사주기' : 'Buy me a coffee',
                  trailing: const Icon(Icons.open_in_new, color: AppColors.gray500, size: 20),
                  onTap: () => _openUrl('https://paypal.me/u2dia'),
                ),
              ),

              const SizedBox(height: 24),

              // Links Section
              _SectionTitle(title: isKo ? '링크' : 'Links'),
              const SizedBox(height: 12),
              DarkCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.public,
                      iconColor: AppColors.purple500,
                      title: isKo ? '웹사이트' : 'Website',
                      subtitle: 'hexacotest.vercel.app',
                      trailing: const Icon(Icons.open_in_new, color: AppColors.gray500, size: 20),
                      onTap: () => _openUrl('https://hexacotest.vercel.app/'),
                    ),
                    const Divider(color: AppColors.darkBorder, height: 1),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: AppColors.emerald500,
                      title: isKo ? '개인정보처리방침' : 'Privacy Policy',
                      trailing: const Icon(Icons.open_in_new, color: AppColors.gray500, size: 20),
                      onTap: () => _openUrl('https://hexacotest.vercel.app/privacy'),
                    ),
                    const Divider(color: AppColors.darkBorder, height: 1),
                    _SettingsTile(
                      icon: Icons.ads_click,
                      iconColor: AppColors.blue500,
                      title: isKo ? '광고 설정' : 'Ad Settings',
                      trailing: const Icon(Icons.open_in_new, color: AppColors.gray500, size: 20),
                      onTap: () => _openUrl('https://www.google.com/settings/ads'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Legal Disclaimer
              DarkCard(
                padding: const EdgeInsets.all(16),
                color: AppColors.darkCard.withValues(alpha: 0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.gray400, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          isKo ? '법적 고지' : 'Legal Disclaimer',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.gray300,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isKo
                          ? '• 본 테스트는 비공식이며 오락/자기이해 목적으로 제공됩니다.\n'
                            '• 결과는 전문 심리 진단을 대체하지 않습니다.\n'
                            '• 개인정보를 수집하지 않으며, 결과는 기기에만 저장됩니다.\n'
                            '• 유명인 매칭은 공개 정보 기반 추정치입니다.\n'
                            '• 본 서비스는 만 16세 이상을 대상으로 합니다.'
                          : '• Unofficial test for entertainment and self-understanding.\n'
                            '• Not a substitute for professional diagnosis.\n'
                            '• We do not collect personal data. Results are stored locally.\n'
                            '• Celebrity matches are estimates based on public info.\n'
                            '• This service is intended for users aged 16 and above.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                            height: 1.6,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      isKo ? '5분 나를 알아보는 시간' : '5 Min to Know Yourself',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6-Type Personality Test v1.0.17',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on 6-Type Personality Theory',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.gray400,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
