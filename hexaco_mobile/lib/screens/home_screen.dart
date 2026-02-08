import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../models/result_history.dart';
import '../services/history_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/ad_banner.dart';
import '../widgets/native_ad.dart';
import '../config/admob_ids.dart';
import '../services/version_check_service.dart';
import 'result_screen.dart';

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
  void initState() {
    super.initState();
    // 앱 시작 시 버전 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    if (!mounted) return;
    final isKo = widget.controller.language == 'ko';
    await VersionCheckService.checkForUpdate(context, isKo: isKo);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLearnMore() {
    final context = _learnMoreKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
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
                isKo: isKo,
                onLearnMore: _scrollToLearnMore,
              ),
              const SizedBox(height: 28),
              _SavedResultsSection(controller: widget.controller, isKo: isKo),
              _StatsSection(isKo: isKo),
              const SizedBox(height: 28),
              _SampleQuestionSection(key: _learnMoreKey, isKo: isKo),
              const SizedBox(height: 28),
              _FeaturesSection(isKo: isKo),
              const SizedBox(height: 28),
              NativeAdSection(
                isKo: isKo,
                titleKo: '추천 콘텐츠',
                titleEn: 'Recommended',
              ),
              const SizedBox(height: 28),
              _HexacoVsMbtiSection(isKo: isKo),
              const SizedBox(height: 28),
              _HexacoSection(isKo: isKo),
              const SizedBox(height: 28),
              _VersionSelectionSection(controller: widget.controller, isKo: isKo),
              const SizedBox(height: 24),
              _DisclaimerSection(isKo: isKo),
              const SizedBox(height: 20),
              BannerAdSection(adUnitId: bannerAdUnitId),
              const SizedBox(height: 16),
              _FooterSection(isKo: isKo),
            ],
          ),
        );
      },
    );
  }
}

class _SavedResultsSection extends StatefulWidget {
  final TestController controller;
  final bool isKo;

  const _SavedResultsSection({required this.controller, required this.isKo});

  @override
  State<_SavedResultsSection> createState() => _SavedResultsSectionState();
}

class _SavedResultsSectionState extends State<_SavedResultsSection> {
  List<ResultHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loaded = await HistoryService.load();
    if (mounted) setState(() => _history = loaded);
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _onTapEntry(ResultHistoryEntry entry) async {
    final pin = await PinDialog.show(
      context,
      isKo: widget.isKo,
      title: widget.isKo ? 'PIN 입력' : 'Enter PIN',
      subtitle: widget.isKo ? '결과를 보려면 PIN을 입력하세요' : 'Enter PIN to view result',
    );
    if (pin == null || !mounted) return;

    if (pin != entry.pin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isKo ? 'PIN이 일치하지 않습니다.' : 'Incorrect PIN.'),
          backgroundColor: AppColors.red500,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          controller: widget.controller,
          data: widget.controller.data,
          savedEntry: entry,
        ),
      ),
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline, color: AppColors.purple400, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.isKo ? '저장된 결과' : 'Saved Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_history.length, (i) {
          final entry = _history[i];
          final profile = widget.controller.data.types.firstWhere(
            (type) => type.id == entry.topMatchId,
            orElse: () => widget.controller.data.types.first,
          );
          final name = widget.isKo ? profile.nameKo : profile.nameEn;

          return Padding(
            padding: EdgeInsets.only(bottom: i < _history.length - 1 ? 8 : 0),
            child: DarkCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTapEntry(entry),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: AppColors.gray500, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatDate(entry.timestamp)} · ${entry.testVersion}${widget.isKo ? '문항' : 'Q'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.gray500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${entry.similarity}%',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.purple400,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: AppColors.gray500, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final TestController controller;
  final bool isKo;
  final VoidCallback onLearnMore;

  const _HeroSection({
    required this.controller,
    required this.isKo,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    final title = 'HEXACO';
    final subtitle = isKo ? '성격 테스트' : 'Personality Test';
    final description = isKo
        ? '세계적으로 권위 있는 심리학 연구를 기반으로 한 HEXACO 모델로\n당신의 성격을 6가지 요인으로 분석합니다.'
        : 'Based on world-renowned psychological research,\nHEXACO analyzes your personality across 6 factors.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final textColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple500.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.purple500.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.purple400),
                  const SizedBox(width: 8),
                  Text(
                    isKo ? '과학적 성격 분석' : 'Scientific Personality Analysis',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.purple400,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GradientText(
              title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
              maxLines: 1,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            _TypingText(
              isKo: isKo,
              items: isKo
                  ? ['진짜 나를 발견하세요', '숨은 성향을 찾아보세요', '나를 알아가는 시작']
                  : ['Discover your true self', 'Find your hidden traits', 'Start knowing yourself'],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.gray400, height: 1.5),
            ),
            const SizedBox(height: 18),
            _QuickVersionSelector(controller: controller, isKo: isKo),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                PrimaryButton(
                  onPressed: () {
                    controller.reset();
                    Navigator.pushNamed(context, '/test');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                SecondaryButton(
                  onPressed: onLearnMore,
                  child: Text(
                    isKo ? '자세히 보기' : 'Learn More',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );

        if (!isWide) {
          return textColumn;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: textColumn),
            const SizedBox(width: 24),
            const Expanded(child: _HexagonHero()),
          ],
        );
      },
    );
  }
}

class _TypingText extends StatefulWidget {
  final bool isKo;
  final List<String> items;

  const _TypingText({required this.isKo, required this.items});

  @override
  State<_TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<_TypingText> {
  int _index = 0;
  Timer? _timer;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.maybeOf(context);
    final reduce = (media?.disableAnimations ?? false) || (media?.accessibleNavigation ?? false);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      if (_reduceMotion) {
        _stopTimer();
      } else {
        _startTimer();
      }
    } else if (!_reduceMotion && _timer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.items.length;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        widget.items[_index],
        key: ValueKey(_index),
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: AppColors.purple400, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _QuickVersionSelector extends StatelessWidget {
  final TestController controller;
  final bool isKo;

  const _QuickVersionSelector({required this.controller, required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: testVersions.map((version) {
        final selected = controller.testVersion == version;
        return InkWell(
          onTap: () => controller.setVersion(version),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.purple500.withValues(alpha: 0.2) : AppColors.darkCard,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? AppColors.purple500 : AppColors.darkBorder,
                width: 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.purple500.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              isKo ? '$version 문항' : '$version questions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? Colors.white : AppColors.gray400,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HexagonHero extends StatefulWidget {
  const _HexagonHero();

  @override
  State<_HexagonHero> createState() => _HexagonHeroState();
}

class _HexagonHeroState extends State<_HexagonHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 30))
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.maybeOf(context);
    final reduce = (media?.disableAnimations ?? false) || (media?.accessibleNavigation ?? false);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      if (_reduceMotion) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _reduceMotion ? 0.0 : _controller.value * 2 * pi;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: angle,
                child: _FactorRing(size: 260),
              ),
              Transform.rotate(
                angle: -angle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.hexagon, size: 120, color: AppColors.purple500.withValues(alpha: 0.5)),
                    Icon(Icons.hexagon, size: 90, color: AppColors.pink500.withValues(alpha: 0.5)),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.purple500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple500.withValues(alpha: 0.4),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FactorRing extends StatelessWidget {
  final double size;

  const _FactorRing({required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: factorOrder.asMap().entries.map((entry) {
          final index = entry.key;
          final factor = entry.value;
          final angle = (index * 60 - 90) * (pi / 180);
          final x = radius + cos(angle) * (radius - 20);
          final y = radius + sin(angle) * (radius - 20);

          return Positioned(
            left: x - 22,
            top: y - 22,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Center(
                child: GradientText(
                  factor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class _StatsSection extends StatelessWidget {
  final bool isKo;

  const _StatsSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        icon: Icons.groups,
        value: '50K+',
        label: isKo ? '테스트 완료' : 'Tests Taken',
      ),
      _StatItem(
        icon: Icons.public,
        value: '180',
        label: isKo ? '심리 질문' : 'Psych Questions',
      ),
      _StatItem(
        icon: Icons.star,
        value: '4.8',
        label: isKo ? '평균 평점' : 'Avg Rating',
      ),
      _StatItem(
        icon: Icons.trending_up,
        value: '97%',
        label: isKo ? '정확도' : 'Accuracy',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) => _StatCard(item: stats[index]),
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

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple500, AppColors.pink500],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleQuestionSection extends StatelessWidget {
  final bool isKo;

  const _SampleQuestionSection({super.key, required this.isKo});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final preview = _SampleQuestionPreview(isKo: isKo);
        final detail = _BenefitsPanel(isKo: isKo);

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              preview,
              const SizedBox(height: 16),
              detail,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: preview),
            const SizedBox(width: 16),
            Expanded(child: detail),
          ],
        );
      },
    );
  }
}

class _SampleQuestionPreview extends StatefulWidget {
  final bool isKo;

  const _SampleQuestionPreview({required this.isKo});

  @override
  State<_SampleQuestionPreview> createState() => _SampleQuestionPreviewState();
}

class _SampleQuestionPreviewState extends State<_SampleQuestionPreview> {
  int _index = 0;
  Timer? _timer;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.maybeOf(context);
    final reduce = (media?.disableAnimations ?? false) || (media?.accessibleNavigation ?? false);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      if (_reduceMotion) {
        _stopTimer();
      } else {
        _startTimer();
      }
    } else if (!_reduceMotion && _timer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % _samples.length;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  List<_SampleQuestion> get _samples => widget.isKo
      ? const [
          _SampleQuestion('H', '친구가 새 옷이 어울리지 않는지 물으면 솔직히 말한다.'),
          _SampleQuestion('E', '무서운 영화를 볼 때 눈을 가리거나 소리를 줄인다.'),
          _SampleQuestion('X', '모임에서 처음 보는 사람에게 먼저 말을 건다.'),
          _SampleQuestion('C', '여행 전 일정과 체크리스트를 꼼꼼히 준비한다.'),
          _SampleQuestion('O', '미술관에서 작품을 보다 보면 시간 가는 줄 모른다.'),
        ]
      : const [
          _SampleQuestion('H', 'If a friend asks about an outfit, I answer honestly.'),
          _SampleQuestion('E', 'When watching scary movies, I cover my eyes or lower the volume.'),
          _SampleQuestion('X', 'At gatherings, I start conversations with strangers.'),
          _SampleQuestion('C', 'I prepare schedules and checklists before traveling.'),
          _SampleQuestion('O', 'I lose track of time when appreciating art.'),
        ];

  @override
  Widget build(BuildContext context) {
    final sample = _samples[_index];
    final color = factorColors[sample.factor] ?? AppColors.purple500;

    return DarkCard(
      radius: AppRadii.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.purple500.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.psychology, color: AppColors.purple400, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isKo ? '샘플 질문 미리보기' : 'Sample Questions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.isKo ? '테스트에서 만나게 될 질문' : 'Questions you will see in the test',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: _reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey(_index),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sample.factor,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  sample.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_samples.length, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.purple500 : AppColors.gray700,
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

class _SampleQuestion {
  final String factor;
  final String text;

  const _SampleQuestion(this.factor, this.text);
}
class _BenefitsPanel extends StatelessWidget {
  final bool isKo;

  const _BenefitsPanel({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final benefits = isKo
        ? const [
            '과학적으로 검증된 HEXACO 모델 기반',
            '상황 기반 질문으로 진짜 성향 파악',
            'AI 없이도 명확한 성격 요약 제공',
            '유형별 100가지 추천 결과',
            '무료로 즉시 결과 확인',
          ]
        : const [
            'Based on scientifically validated HEXACO model',
            'Situation-based questions reveal true traits',
            'Clear summary without AI dependency',
            '100-type recommendations',
            'Free instant results',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? '단순 질문이 아닌, 상황 기반 분석' : 'Not simple questions, situation-based analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          isKo
              ? '"나는 정직하다" 같은 직접 질문 대신, 실제 상황에서의 행동을 묻습니다.'
              : 'Instead of direct claims, we ask how you behave in real situations.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 16),
        Column(
          children: benefits
              .map((text) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.purple500, AppColors.pink500]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 16, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray300),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
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
        title: isKo ? '과학적 분석' : 'Scientific Analysis',
        description: isKo ? '검증된 HEXACO-60 문항 기반' : 'Validated HEXACO-60 questionnaire',
      ),
      _FeatureItem(
        icon: Icons.people_alt,
        title: isKo ? '유형 매칭' : 'Persona Matching',
        description: isKo ? '가장 가까운 유형 5개 추천' : 'Top 5 closest matches',
      ),
      _FeatureItem(
        icon: Icons.share,
        title: isKo ? '결과 공유' : 'Share Results',
        description: isKo ? '간편한 결과 공유와 저장' : 'Easy sharing and saving',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 3.2 : 1.6,
          ),
          itemBuilder: (context, index) => _FeatureCard(item: features[index]),
        );
      },
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({required this.icon, required this.title, required this.description});
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;

  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      radius: AppRadii.xl,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.purple500, AppColors.pink500]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HexacoVsMbtiSection extends StatelessWidget {
  final bool isKo;

  const _HexacoVsMbtiSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final rows = [
      {
        'label': isKo ? '요인 수' : 'Factors',
        'hexaco': isKo ? '6개 요인 (수치화)' : '6 factors (scored)',
        'mbti': isKo ? '4개 요인 (이분법)' : '4 factors (binary)',
      },
      {
        'label': isKo ? '측정 방식' : 'Measurement',
        'hexaco': isKo ? '연속 스펙트럼\n(0~100점)' : 'Continuous\n(0–100)',
        'mbti': isKo ? '유형 분류\n(16가지)' : 'Type classification\n(16 types)',
      },
      {
        'label': isKo ? '정직-겸손' : 'Honesty-\nHumility',
        'hexaco': isKo ? '포함\n(독자적 요인)' : 'Included\n(unique factor)',
        'mbti': isKo ? '미포함' : 'Not included',
      },
      {
        'label': isKo ? '주요 목적' : 'Purpose',
        'hexaco': isKo ? '자기 이해와 성장' : 'Self-understanding\n& growth',
        'mbti': isKo ? '유형 분류' : 'Type classification',
      },
      {
        'label': isKo ? '학술 근거' : 'Evidence',
        'hexaco': isKo ? '국제 학술 연구 기반' : 'International\nacademic research',
        'mbti': isKo ? '경험적 분류' : 'Empirical\nclassification',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? 'HEXACO vs MBTI, 뭐가 다를까?' : 'HEXACO vs MBTI: What\'s Different?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          isKo
              ? 'HEXACO는 MBTI보다 더 정밀한 과학적 성격 분석 모델입니다.'
              : 'HEXACO is a more precise, scientific personality model than MBTI.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 16),
        DarkCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
                ),
                child: Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: GradientText(
                            'HEXACO',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'MBTI',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              for (var i = 0; i < rows.length; i++)
                Container(
                  decoration: BoxDecoration(
                    border: i < rows.length - 1
                        ? Border(bottom: BorderSide(color: AppColors.darkBorder))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            rows[i]['label']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray400,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: AppColors.darkBorder),
                              right: BorderSide(color: AppColors.darkBorder),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            rows[i]['hexaco']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.purple400,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            rows[i]['mbti']!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray500,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HexacoSection extends StatelessWidget {
  final bool isKo;

  const _HexacoSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final descriptionsKo = const {
      'H': '정직, 공정성, 겸손을 중시합니다.',
      'E': '불안, 공포, 정서적 민감성에 관련됩니다.',
      'X': '사회적 자신감과 활력을 나타냅니다.',
      'A': '관용과 협력적인 태도를 의미합니다.',
      'C': '체계성, 성실함, 주의성을 보여줍니다.',
      'O': '창의성과 새로운 경험에 대한 개방성입니다.',
    };
    final descriptionsEn = const {
      'H': 'Honesty, fairness, and humility.',
      'E': 'Anxiety, fearfulness, emotional sensitivity.',
      'X': 'Social confidence and energy.',
      'A': 'Tolerance and cooperative attitude.',
      'C': 'Organization and diligence.',
      'O': 'Creativity and openness to new experience.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? 'HEXACO 모델이란?' : 'What is the HEXACO Model?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          isKo
              ? 'HEXACO는 Big Five에 정직-겸손 요인을 추가한 성격 구조 모델입니다.'
              : 'HEXACO extends Big Five with Honesty-Humility for more precise traits.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: factorOrder.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final factor = factorOrder[index];
                final color = factorColors[factor] ?? AppColors.purple500;
                return DarkCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factor,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKo ? factorNamesKo[factor] ?? '' : factorNamesEn[factor] ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKo ? descriptionsKo[factor] ?? '' : descriptionsEn[factor] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
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
class _VersionSelectionSection extends StatelessWidget {
  final TestController controller;
  final bool isKo;

  const _VersionSelectionSection({required this.controller, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final versions = [
      _VersionCard(
        value: 60,
        minutes: 5,
        title: isKo ? '빠른 테스트' : 'Quick Test',
        description: isKo ? '기본 성격 특성을 빠르게 확인합니다.' : 'Quick overview of core traits.',
        icon: Icons.bolt,
      ),
      _VersionCard(
        value: 120,
        minutes: 10,
        title: isKo ? '표준 테스트' : 'Standard Test',
        description: isKo ? '균형 잡힌 분석으로 정확도를 높입니다.' : 'Balanced analysis with better accuracy.',
        icon: Icons.schedule,
      ),
      _VersionCard(
        value: 180,
        minutes: 15,
        title: isKo ? '정밀 테스트' : 'Detailed Test',
        description: isKo ? '가장 정교한 성격 분석을 제공합니다.' : 'Deepest and most detailed analysis.',
        icon: Icons.track_changes,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isKo ? '테스트 길이를 선택하세요' : 'Choose Test Length',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          isKo ? '문항이 많을수록 더 정밀한 결과를 제공합니다.' : 'More questions give more precise results.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: versions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: columns == 1 ? 1.6 : 1.2,
              ),
              itemBuilder: (context, index) {
                final card = versions[index];
                final selected = controller.testVersion == card.value;
                return InkWell(
                  onTap: () => controller.setVersion(card.value),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  child: DarkCard(
                    radius: AppRadii.xl,
                    borderColor: selected ? AppColors.purple500 : null,
                    color: selected ? AppColors.purple500.withValues(alpha: 0.08) : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.purple500 : AppColors.darkBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(card.icon, color: selected ? Colors.white : AppColors.purple400),
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
                        const SizedBox(height: 12),
                        Text(
                          '${card.value}${isKo ? '문항' : ' questions'}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          card.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.gray500),
                            const SizedBox(width: 6),
                            Text(
                              isKo ? '약 ${card.minutes}분' : 'About ${card.minutes} min',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
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
              Text(isKo ? '테스트 시작' : 'Start Test'),
            ],
          ),
        ),
      ],
    );
  }
}

class _VersionCard {
  final int value;
  final int minutes;
  final String title;
  final String description;
  final IconData icon;

  const _VersionCard({
    required this.value,
    required this.minutes,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _DisclaimerSection extends StatelessWidget {
  final bool isKo;

  const _DisclaimerSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    final notices = isKo
        ? const [
            '⚠️ 본 테스트는 비공식이며 HEXACO-PI-R과 무관합니다.',
            '🎭 결과는 오락 및 자기이해 목적이며 전문 심리 진단을 대체하지 않습니다.',
            '✍️ 모든 문항은 독자적으로 제작된 상황 기반 문항입니다.',
            '🔒 개인정보를 수집하지 않으며, 테스트 결과는 기기에만 저장됩니다.',
            '👤 유명인 매칭은 공개 정보 기반 추정치이며 실제 성격과 다를 수 있습니다.',
            '🔞 본 서비스는 만 16세 이상을 대상으로 합니다.',
          ]
        : const [
            '⚠️ This is an unofficial test and NOT affiliated with HEXACO-PI-R.',
            '🎭 Results are for entertainment/self-understanding only, not professional diagnosis.',
            '✍️ All questions are original situation-based items.',
            '🔒 We do not collect personal data. Results are stored locally on your device.',
            '👤 Celebrity matches are estimates based on public info, not actual personalities.',
            '🔞 This service is intended for users aged 16 and above.',
          ];

    return DarkCard(
      radius: AppRadii.xl,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.gray400, size: 18),
              const SizedBox(width: 8),
              Text(
                isKo ? '법적 고지' : 'Legal Notice',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...notices.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              )),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final bool isKo;

  const _FooterSection({required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'HEXACO Personality Test',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: 6),
        Text(
          isKo
              ? 'HEXACO 이론 기반 (Ashton & Lee) | 비공식 테스트'
              : 'Based on HEXACO theory (Ashton & Lee) | Unofficial Test',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
