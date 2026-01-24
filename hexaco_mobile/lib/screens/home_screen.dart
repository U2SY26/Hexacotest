import 'dart:async';

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
import '../widgets/glass_container.dart';
import '../services/history_service.dart';

class HomeScreen extends StatefulWidget {
  final TestController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _learnMoreKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLearnMore() {
    final context = _learnMoreKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final isKo = widget.controller.language == 'ko';

        return AppScaffold(
          appBar: AppHeader(controller: widget.controller),
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(
                controller: widget.controller,
                onLearnMore: _scrollToLearnMore,
              ),
              const SizedBox(height: 28),
              _StatsSection(isKo: isKo),
              const SizedBox(height: 28),
              KeyedSubtree(
                key: _learnMoreKey,
                child: _SampleAndBenefits(isKo: isKo),
              ),
              const SizedBox(height: 28),
              _FeaturesSection(isKo: isKo),
              const SizedBox(height: 28),
              _HexacoFactorsSection(isKo: isKo),
              const SizedBox(height: 28),
              _VersionSelection(controller: widget.controller),
              const SizedBox(height: 28),
              BannerAdSection(adUnitId: bannerAdUnitId),
              const SizedBox(height: 20),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                radius: AppRadii.lg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKo ? '법적 고지' : 'Legal Notice',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isKo
                          ? '본 테스트는 비공식이며 참고용입니다. 전문 진단을 대체하지 않습니다.'
                          : 'This is an unofficial test for reference only and does not replace professional assessment.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isKo
                          ? '모든 결과는 기기 내에만 저장되며 서버로 전송되지 않습니다.'
                          : 'All results are stored locally on your device and are not sent to a server.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SecondaryButton(
                        onPressed: () async {
                          await HistoryService.clear();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isKo ? '저장된 기록을 삭제했어요.' : 'Local history cleared.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          isKo ? '로컬 기록 삭제' : 'Clear local history',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
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
  final VoidCallback onLearnMore;

  const _HeroSection({
    required this.controller,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final isKo = controller.language == 'ko';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          radius: 999,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.purple500, size: 16),
              const SizedBox(width: 8),
              Text(
                isKo ? '과학적 성격 분석' : 'Scientific Personality Analysis',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.purple400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GradientText(
          isKo ? 'HEXACO 성향 테스트' : 'HEXACO Personality Test',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          isKo ? '나의 진짜 성향을 발견해보세요' : 'Discover your true personality profile',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          isKo
              ? '상황 기반 질문으로 사회적 바람직성 편향을 줄이고 실제 행동 성향을 측정합니다.'
              : 'Situation-based questions reduce social desirability bias and reveal real behavior patterns.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 20),
        _VersionPills(controller: controller),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: () {
                  controller.reset();
                  Navigator.pushNamed(context, '/test');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isKo ? '테스트 시작' : 'Start Test',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                onPressed: onLearnMore,
                child: Text(
                  isKo ? '자세히 보기' : 'Learn More',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VersionPills extends StatelessWidget {
  final TestController controller;

  const _VersionPills({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: testVersions.map((version) {
        final isSelected = controller.testVersion == version;
        return InkWell(
          onTap: () => controller.setVersion(version),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.purple500.withValues(alpha: 0.2)
                  : AppColors.darkCard,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? AppColors.purple500 : AppColors.darkBorder,
              ),
            ),
            child: Text(
              '$version',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.gray400,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final bool isKo;

  const _StatsSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(icon: Icons.people, value: '50K+', label: isKo ? '테스트 완료' : 'Tests Taken'),
      _StatItem(icon: Icons.psychology, value: '180', label: isKo ? '심리 질문' : 'Questions'),
      _StatItem(icon: Icons.star, value: '4.8', label: isKo ? '평점' : 'Rating'),
      _StatItem(icon: Icons.trending_up, value: '97%', label: isKo ? '정확도' : 'Accuracy'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 820 ? 4 : width >= 560 ? 3 : 2;
        return GridView.builder(
          itemCount: stats.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, index) {
            final item = stats[index];
            return DarkCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.purple500.withValues(alpha: 0.25),
                          AppColors.pink500.withValues(alpha: 0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.gray400),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});
}

class _SampleAndBenefits extends StatelessWidget {
  final bool isKo;

  const _SampleAndBenefits({required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? '샘플 질문 미리보기' : 'Sample Questions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _SampleQuestionCard(isKo: isKo),
        const SizedBox(height: 16),
        Text(
          isKo ? '이 테스트의 특징' : 'Why this test?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            _BenefitRow(text: isKo ? '과학적 HEXACO 모델 기반' : 'Based on the HEXACO model'),
            _BenefitRow(text: isKo ? '상황 기반 질문으로 실제 행동 측정' : 'Situation-based questions'),
            _BenefitRow(text: isKo ? '100가지 유형 중 맞춤 추천' : 'Top matches among 100 types'),
          ],
        ),
      ],
    );
  }
}

class _SampleQuestionCard extends StatefulWidget {
  final bool isKo;

  const _SampleQuestionCard({required this.isKo});

  @override
  State<_SampleQuestionCard> createState() => _SampleQuestionCardState();
}

class _SampleQuestionCardState extends State<_SampleQuestionCard> {
  late final Timer _timer;
  int _index = 0;

  final _samples = const [
    _SampleItem(
      factor: 'H',
      ko: '친구의 새 옷이 어울리지 않을 때 솔직하게 말한다.',
      en: 'If a friend asked how their new outfit looked and it did not suit them, I would say so.',
    ),
    _SampleItem(
      factor: 'E',
      ko: '무서운 영화를 볼 때 눈을 가리곤 한다.',
      en: 'I tend to cover my eyes when watching scary movies.',
    ),
    _SampleItem(
      factor: 'X',
      ko: '모임에서 처음 보는 사람에게 먼저 말을 건다.',
      en: 'At gatherings, I approach strangers to start conversations.',
    ),
    _SampleItem(
      factor: 'C',
      ko: '여행 전 상세한 일정과 체크리스트를 준비한다.',
      en: 'Before trips, I prepare detailed schedules and checklists.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        _index = (_index + 1) % _samples.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = _samples[_index];
    final color = factorColors[item.factor] ?? Colors.white;

    return DarkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.factor,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              widget.isKo ? item.ko : item.en,
              key: ValueKey(_index),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_samples.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.purple500 : AppColors.gray700,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SampleItem {
  final String factor;
  final String ko;
  final String en;

  const _SampleItem({required this.factor, required this.ko, required this.en});
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionSelection extends StatelessWidget {
  final TestController controller;

  const _VersionSelection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isKo = controller.language == 'ko';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? '테스트 버전 선택' : 'Choose a version',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Column(
          children: testVersions.map((version) {
            final selected = controller.testVersion == version;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => controller.setVersion(version),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: DarkCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: selected ? AppColors.purple500 : AppColors.darkBorder,
                  color: selected
                      ? AppColors.purple500.withValues(alpha: 0.1)
                      : AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.purple500
                              : AppColors.purple500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          version == 60
                              ? Icons.bolt
                              : version == 120
                                  ? Icons.schedule
                                  : Icons.track_changes,
                          color: selected ? Colors.white : AppColors.purple400,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKo ? versionLabelKo(version) : versionLabelEn(version),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isKo
                                  ? '$version문항 · 약 ${version == 60 ? 5 : version == 120 ? 10 : 15}분'
                                  : '$version items · ${version == 60 ? 5 : version == 120 ? 10 : 15} min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray400),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purple500,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isKo ? '선택됨' : 'Selected',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  final bool isKo;

  const _FeaturesSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.psychology,
        title: isKo ? '과학적 모델' : 'Scientific Model',
        description: isKo
            ? 'HEXACO 이론 기반의 구조적 성격 분석'
            : 'Structured assessment based on the HEXACO model',
      ),
      _FeatureItem(
        icon: Icons.groups,
        title: isKo ? '100가지 유형 추천' : '100 Type Matches',
        description: isKo
            ? '가장 가까운 성향 유형을 추천'
            : 'Recommend the closest matching personality type',
      ),
      _FeatureItem(
        icon: Icons.share,
        title: isKo ? '간편한 결과 공유' : 'Easy Sharing',
        description: isKo
            ? '모바일에 최적화된 결과 화면'
            : 'Mobile-friendly results for quick sharing',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? '주요 특징' : 'Key Features',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Column(
          children: features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DarkCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple500.withValues(alpha: 0.2),
                            AppColors.pink500.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(feature.icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature.description,
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _HexacoFactorsSection extends StatelessWidget {
  final bool isKo;

  const _HexacoFactorsSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final descriptionsKo = {
      'H': '정직성과 겸손, 공정성 중심의 태도',
      'E': '정서적 민감성과 불안 반응 경향',
      'X': '사회적 자신감과 활력',
      'A': '온화함과 인내, 관용',
      'C': '체계적이고 성실한 실행력',
      'O': '호기심과 창의적 사고',
    };
    final descriptionsEn = {
      'H': 'Honesty, humility, and fairness',
      'E': 'Emotional sensitivity and anxiety',
      'X': 'Social confidence and energy',
      'A': 'Gentleness, patience, and tolerance',
      'C': 'Structured and diligent execution',
      'O': 'Curiosity and creativity',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? 'HEXACO 6요인' : 'HEXACO Factors',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 820 ? 3 : 2;
            return GridView.builder(
              itemCount: factorOrder.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final factor = factorOrder[index];
                final color = factorColors[factor] ?? Colors.white;
                return DarkCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factor,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKo ? factorNamesKo[factor] ?? '' : factorNamesEn[factor] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKo ? descriptionsKo[factor] ?? '' : descriptionsEn[factor] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.gray400),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
