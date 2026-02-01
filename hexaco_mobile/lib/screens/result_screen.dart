import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../data/data_repository.dart';
import '../models/score.dart';
import '../models/result_history.dart';
import '../services/recommendation_service.dart';
import '../services/history_service.dart';
import '../services/personality_analysis_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/radar_chart.dart';
import '../widgets/ad_banner.dart';
import '../config/admob_ids.dart';

class ResultScreen extends StatefulWidget {
  final TestController controller;
  final AppData data;

  const ResultScreen({super.key, required this.controller, required this.data});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late Scores scores;
  late List<TypeMatch> matches;
  List<ResultHistoryEntry> _history = [];
  bool _saved = false;
  bool _isLoading = true;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _celebrationController;

  final List<String> _loadingMessagesKo = [
    '당신의 성격을 분석하고 있어요...',
    '6가지 요인을 계산 중...',
    '100가지 유형과 비교하는 중...',
    '가장 비슷한 유형을 찾고 있어요...',
    '두근두근... 🎭',
    '결과를 준비하고 있어요...',
  ];

  final List<String> _loadingMessagesEn = [
    'Analyzing your personality...',
    'Calculating 6 factors...',
    'Comparing with 100 types...',
    'Finding your closest match...',
    'Drumroll please... 🎭',
    'Preparing your results...',
  ];

  @override
  void initState() {
    super.initState();
    scores = widget.controller.calculateScores();
    matches = RecommendationService.topMatches(scores, widget.data.types, count: 5);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _startLoadingAnimation();
    _saveAndLoadHistory();
  }

  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadingMessageIndex++;
        if (_loadingMessageIndex >= _loadingMessagesKo.length) {
          timer.cancel();
          _finishLoading();
        }
      });
    });
  }

  void _finishLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _fadeController.forward();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _fadeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  String _getFunQuote(bool isKo) {
    final similarity = matches.first.similarity;
    if (similarity >= 90) {
      return isKo ? '🎉 와! 거의 쌍둥이 수준이에요!' : '🎉 Wow! Almost twins!';
    } else if (similarity >= 80) {
      return isKo ? '✨ 정말 닮았네요! 혹시 친척?' : '✨ So similar! Are you related?';
    } else if (similarity >= 70) {
      return isKo ? '🌟 꽤 비슷해요! 같은 바이브!' : '🌟 Pretty similar! Same vibe!';
    } else if (similarity >= 60) {
      return isKo ? '💫 닮은 구석이 있어요!' : '💫 Some resemblance!';
    } else {
      return isKo ? '🦄 당신은 유니크해요!' : '🦄 You are unique!';
    }
  }

  String _getPersonalityBadge(bool isKo) {
    // 가장 높은 요인 찾기
    final scoreMap = scores.toMap();
    String highestFactor = 'H';
    double highestScore = 0;
    scoreMap.forEach((key, value) {
      if (value > highestScore) {
        highestScore = value;
        highestFactor = key;
      }
    });

    final badges = isKo ? {
      'H': '🏆 정직왕',
      'E': '💝 감성러버',
      'X': '🎤 파티피플',
      'A': '🤝 화합마스터',
      'C': '📋 계획장인',
      'O': '🎨 창의천재',
    } : {
      'H': '🏆 Honesty King',
      'E': '💝 Emotion Lover',
      'X': '🎤 Party People',
      'A': '🤝 Harmony Master',
      'C': '📋 Plan Expert',
      'O': '🎨 Creative Genius',
    };

    return badges[highestFactor] ?? (isKo ? '⭐ 균형잡힌 성격' : '⭐ Balanced Soul');
  }

  Future<void> _saveAndLoadHistory() async {
    if (!_saved) {
      final entry = ResultHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        scores: scores.toMap(),
        topMatchId: matches.first.profile.id,
        similarity: matches.first.similarity,
      );
      await HistoryService.save(entry);
      _saved = true;
    }
    final loaded = await HistoryService.load();
    if (mounted) {
      setState(() {
        _history = loaded;
      });
    }
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  String _summaryText(bool isKo) {
    final topMatch = matches.first;
    return isKo
        ? '내 HEXACO 결과: ${topMatch.profile.nameKo} (${topMatch.similarity}%)\n'
            'H ${scores.h.toStringAsFixed(1)} / E ${scores.e.toStringAsFixed(1)} / X ${scores.x.toStringAsFixed(1)} / '
            'A ${scores.a.toStringAsFixed(1)} / C ${scores.c.toStringAsFixed(1)} / O ${scores.o.toStringAsFixed(1)}'
        : 'My HEXACO result: ${topMatch.profile.nameEn} (${topMatch.similarity}%)\n'
            'H ${scores.h.toStringAsFixed(1)} / E ${scores.e.toStringAsFixed(1)} / X ${scores.x.toStringAsFixed(1)} / '
            'A ${scores.a.toStringAsFixed(1)} / C ${scores.c.toStringAsFixed(1)} / O ${scores.o.toStringAsFixed(1)}';
  }

  Future<void> _copySummary(bool isKo) async {
    await Clipboard.setData(ClipboardData(text: _summaryText(isKo)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isKo ? '결과가 복사되었습니다.' : 'Result copied.'),
      ),
    );
  }

  Future<void> _shareAsImage(bool isKo) async {
    final shareKey = GlobalKey();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ShareImageDialog(
        shareKey: shareKey,
        matches: matches,
        scores: scores,
        isKo: isKo,
        summaryText: _summaryText(isKo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKo = widget.controller.language == 'ko';
    final topMatch = matches.first;
    final historyPreview = _history.take(5).toList(growable: false);

    if (_isLoading) {
      return _LoadingScreen(
        isKo: isKo,
        messageIndex: _loadingMessageIndex,
        messages: isKo ? _loadingMessagesKo : _loadingMessagesEn,
      );
    }

    return AppScaffold(
      appBar: AppHeader(controller: widget.controller),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            isKo ? '결과' : 'Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isKo
                ? '100가지 유형 중 가장 가까운 유형을 추천합니다.'
                : 'We recommend the closest match among 100 types.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          // 재미있는 배지
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple500, AppColors.pink500],
                ),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple500.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                _getPersonalityBadge(isKo),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 재미있는 인용구
          Center(
            child: Text(
              _getFunQuote(isKo),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.purple400,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          DarkCard(
            radius: AppRadii.xl,
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn)
                          .characters
                          .first,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKo ? topMatch.profile.descriptionKo : topMatch.profile.descriptionEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.gray400),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            isKo ? '유사도 ${topMatch.similarity}%' : 'Similarity ${topMatch.similarity}%',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.purple400),
                          ),
                          const SizedBox(width: 8),
                          if (topMatch.similarity >= 80)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.emerald500.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isKo ? '찰떡궁합!' : 'Perfect Match!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.emerald500,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DarkCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo ? '프로필 지도' : 'Profile Map',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Center(child: RadarChart(scores: scores.toMap(), size: 240)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isKo ? '요인 점수' : 'Factor Scores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 820 ? 3 : 2;
              return GridView.builder(
                itemCount: factorOrder.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final factor = factorOrder[index];
                  final value = scores.toMap()[factor] ?? 0;
                  return DarkCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              factor,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: factorColors[factor],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isKo ? factorNamesKo[factor] ?? '' : factorNamesEn[factor] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.gray400),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${value.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: value / 100,
                          color: factorColors[factor],
                          backgroundColor: factorColors[factor]?.withValues(alpha: 0.2),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          _PersonalityAnalysisCard(scores: scores, isKo: isKo),
          const SizedBox(height: 16),
          Text(
            isKo ? '추천 유형 TOP 5' : 'Top 5 Matches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x332A1F4F), Color(0x332D1B3C)],
              ),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.darkBorder),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < matches.length; i += 1) ...[
                  _MatchRow(match: matches[i], isKo: isKo, rank: i + 1),
                  if (i != matches.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isKo
                ? '※ 유명인 매칭은 공개 정보 기반 추정치이며 실제 성격과 다를 수 있습니다.'
                : '※ Celebrity matches are estimates based on public info and may differ from actual personalities.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gray500,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
          if (historyPreview.isNotEmpty) ...[
            const SizedBox(height: 16),
            DarkCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                collapsedIconColor: AppColors.gray400,
                iconColor: AppColors.gray400,
                title: Text(
                  isKo ? '최근 기록' : 'Recent Results',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  for (var i = 0; i < historyPreview.length; i += 1) ...[
                    _HistoryRow(
                      name: (() {
                        final profile = widget.data.types.firstWhere(
                          (type) => type.id == historyPreview[i].topMatchId,
                          orElse: () => widget.data.types.first,
                        );
                        return isKo ? profile.nameKo : profile.nameEn;
                      })(),
                      date: _formatDate(historyPreview[i].timestamp),
                      similarity: historyPreview[i].similarity,
                    ),
                    if (i != historyPreview.length - 1) const SizedBox(height: 12),
                  ]
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          BannerAdSection(adUnitId: bannerAdUnitId),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SecondaryButton(
                onPressed: () => _copySummary(isKo),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 18),
                    const SizedBox(width: 8),
                    Text(isKo ? '결과 복사' : 'Copy Result'),
                  ],
                ),
              ),
              SecondaryButton(
                onPressed: () => _shareAsImage(isKo),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image, size: 18),
                    const SizedBox(width: 8),
                    Text(isKo ? '이미지 공유' : 'Share Image'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  onPressed: () {
                    widget.controller.reset();
                    Navigator.pushNamedAndRemoveUntil(context, '/test', (route) => false);
                  },
                  child: Text(
                    isKo ? '다시하기' : 'Retry',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  onPressed: () {
                    widget.controller.reset();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  child: Text(
                    isKo ? '홈으로' : 'Home',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DarkCard(
            padding: const EdgeInsets.all(12),
            color: AppColors.darkCard.withValues(alpha: 0.7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.gray400),
                    const SizedBox(width: 8),
                    Text(
                      isKo ? '법적 고지' : 'Legal Notice',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isKo
                      ? '• 본 테스트는 비공식이며 HEXACO-PI-R과 무관합니다.\n'
                        '• 결과는 오락 및 자기이해 목적이며 전문 심리 진단을 대체하지 않습니다.\n'
                        '• 테스트 결과는 기기에만 저장되며 수집하지 않습니다.'
                      : '• Unofficial test, not affiliated with HEXACO-PI-R.\n'
                        '• For entertainment/self-understanding only, not professional diagnosis.\n'
                        '• Results are stored locally and not collected.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                        fontSize: 11,
                        height: 1.5,
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

class _LoadingScreen extends StatefulWidget {
  final bool isKo;
  final int messageIndex;
  final List<String> messages;

  const _LoadingScreen({
    required this.isKo,
    required this.messageIndex,
    required this.messages,
  });

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.messageIndex < widget.messages.length
        ? widget.messages[widget.messageIndex]
        : widget.messages.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.1);
                final glow = 0.3 + (_pulseController.value * 0.4);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.purple500, AppColors.pink500],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple500.withValues(alpha: glow),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.pink500.withValues(alpha: glow * 0.5),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                message,
                key: ValueKey(widget.messageIndex),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: (widget.messageIndex + 1) / widget.messages.length,
                backgroundColor: AppColors.darkCard,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple500),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${((widget.messageIndex + 1) / widget.messages.length * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalityAnalysisCard extends StatefulWidget {
  final Scores scores;
  final bool isKo;

  const _PersonalityAnalysisCard({required this.scores, required this.isKo});

  @override
  State<_PersonalityAnalysisCard> createState() => _PersonalityAnalysisCardState();
}

class _PersonalityAnalysisCardState extends State<_PersonalityAnalysisCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final analysis = PersonalityAnalysisService.getAnalysis(widget.scores, widget.isKo);

    return DarkCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purple500, AppColors.pink500],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isKo ? '성격 분석 리포트' : 'Personality Analysis Report',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isKo ? '탭하여 상세 분석 보기' : 'Tap to view detailed analysis',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray400,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.gray400),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.darkBorder),
                  const SizedBox(height: 12),
                  Text(
                    analysis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray300,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final TypeMatch match;
  final bool isKo;
  final int rank;

  const _MatchRow({required this.match, required this.isKo, required this.rank});

  @override
  Widget build(BuildContext context) {
    final name = isKo ? match.profile.nameKo : match.profile.nameEn;
    final description = isKo ? match.profile.descriptionKo : match.profile.descriptionEn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryButton,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.characters.first,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#$rank',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${match.similarity}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.purple400),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String name;
  final String date;
  final int similarity;

  const _HistoryRow({
    required this.name,
    required this.date,
    required this.similarity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
        Text(
          '$similarity%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.purple400),
        ),
      ],
    );
  }
}

class _ShareImageDialog extends StatefulWidget {
  final GlobalKey shareKey;
  final List<TypeMatch> matches;
  final Scores scores;
  final bool isKo;
  final String summaryText;

  const _ShareImageDialog({
    required this.shareKey,
    required this.matches,
    required this.scores,
    required this.isKo,
    required this.summaryText,
  });

  @override
  State<_ShareImageDialog> createState() => _ShareImageDialogState();
}

class _ShareImageDialogState extends State<_ShareImageDialog> {
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndShare();
    });
  }

  Future<void> _captureAndShare() async {
    setState(() => _isCapturing = true);

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final boundary = widget.shareKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hexaco_result.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.summaryText,
      );
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      await Share.share(widget.summaryText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topMatch = widget.matches.first;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCapturing)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.purple500),
            ),
          RepaintBoundary(
            key: widget.shareKey,
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1035), Color(0xFF2D1B4E)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.purple500.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hexagon, color: AppColors.purple500, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'HEXACO',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (widget.isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn)
                            .characters
                            .first,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isKo ? '유사도 ${topMatch.similarity}%' : 'Similarity ${topMatch.similarity}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.purple400,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.isKo ? 'TOP 5 매칭' : 'TOP 5 Matches',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.gray400,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.matches.take(5).map((match) {
                    final name = widget.isKo ? match.profile.nameKo : match.profile.nameEn;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.purple500, AppColors.pink500],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                name.characters.first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${match.similarity}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.purple400,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'hexacotest.vercel.app',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
