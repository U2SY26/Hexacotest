import 'package:flutter/material.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/ad_banner.dart';
import '../config/admob_ids.dart';
import '../widgets/gradient_text.dart';

class HomeScreen extends StatelessWidget {
  final TestController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isKo = controller.language == 'ko';

        return AppScaffold(
          appBar: AppHeader(controller: controller),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(controller: controller),
              const SizedBox(height: 24),
              _VersionSelector(controller: controller),
              const SizedBox(height: 20),
              PrimaryButton(
                onPressed: () {
                  controller.reset();
                  Navigator.pushNamed(context, '/test');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      isKo ? '테스트 시작' : 'Start Test',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isKo ? '5-15분이면 충분합니다.' : '5–15 minutes is enough.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 24),
              _InfoSection(isKo: isKo),
              const SizedBox(height: 20),
              BannerAdSection(adUnitId: bannerAdUnitId),
              const SizedBox(height: 16),
              Text(
                isKo
                    ? '결과는 기기에만 저장되며 서버로 전송되지 않습니다.'
                    : 'Results are stored locally and never sent to a server.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TestController controller;

  const _HeroSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isKo = controller.language == 'ko';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          isKo ? '나를 알아보기 위한 투자' : 'Invest in Knowing Yourself',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Text(
          isKo
              ? '상황 기반 질문으로 진짜 성향을 발견합니다.'
              : 'Discover your true traits with situation-based questions.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          isKo
              ? '불필요한 설명은 줄이고, 결과에 집중했습니다.'
              : 'No noise. Just focus and clear results.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }
}

class _VersionSelector extends StatelessWidget {
  final TestController controller;

  const _VersionSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isKo = controller.language == 'ko';

    return DarkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isKo ? '테스트 길이' : 'Test Length',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: testVersions.map((version) {
              final selected = controller.testVersion == version;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => controller.setVersion(version),
                selectedColor: AppColors.purple500.withValues(alpha: 0.2),
                backgroundColor: AppColors.darkBg,
                label: Text(
                  isKo ? versionLabelKo(version) : versionLabelEn(version),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.gray400,
                  fontWeight: FontWeight.w600,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected ? AppColors.purple500 : AppColors.darkBorder,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final bool isKo;

  const _InfoSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(16),
      child: ExpansionTile(
        collapsedIconColor: AppColors.gray400,
        iconColor: AppColors.gray400,
        title: Text(
          isKo ? 'HEXACO란?' : 'What is HEXACO?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo
                      ? '정직-겸손, 정서성, 외향성, 우호성, 성실성, 개방성의 6요인으로 성격을 설명합니다.'
                      : 'A six-factor personality model: H, E, X, A, C, and O.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray400),
                ),
                const SizedBox(height: 8),
                Text(
                  isKo
                      ? '이 테스트는 오락/자기이해 목적이며 전문 진단을 대체하지 않습니다.'
                      : 'For self-understanding and entertainment only.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
