import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../data/data_repository.dart';
import '../models/score.dart';
import '../models/result_history.dart';
import '../services/recommendation_service.dart';
import '../services/history_service.dart';
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

class _ResultScreenState extends State<ResultScreen> {
  late Scores scores;
  late List<TypeMatch> matches;
  List<ResultHistoryEntry> _history = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    scores = widget.controller.calculateScores();
    matches = RecommendationService.topMatches(scores, widget.data.types, count: 5);
    _saveAndLoadHistory();
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

  Future<void> _shareSummary(bool isKo) async {
    final topMatch = matches.first;
    final text = isKo
        ? '내 HEXACO 결과: ${topMatch.profile.nameKo} (${topMatch.similarity}%)\n'
            'H ${scores.h.toStringAsFixed(1)} / E ${scores.e.toStringAsFixed(1)} / X ${scores.x.toStringAsFixed(1)} / '
            'A ${scores.a.toStringAsFixed(1)} / C ${scores.c.toStringAsFixed(1)} / O ${scores.o.toStringAsFixed(1)}'
        : 'My HEXACO result: ${topMatch.profile.nameEn} (${topMatch.similarity}%)\n'
            'H ${scores.h.toStringAsFixed(1)} / E ${scores.e.toStringAsFixed(1)} / X ${scores.x.toStringAsFixed(1)} / '
            'A ${scores.a.toStringAsFixed(1)} / C ${scores.c.toStringAsFixed(1)} / O ${scores.o.toStringAsFixed(1)}';

    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isKo = widget.controller.language == 'ko';
    final topMatch = matches.first;
    final historyPreview = _history.take(5).toList(growable: false);

    return AppScaffold(
      appBar: AppHeader(controller: widget.controller),
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
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          DarkCard(
            radius: AppRadii.xl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo ? '가장 가까운 유형' : 'Closest Match',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.gray400),
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${topMatch.similarity}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.purple400, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isKo ? '유사도' : 'Similarity',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              final chartCard = DarkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKo ? '프로필 지도' : 'Profile Map',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Center(child: RadarChart(scores: scores.toMap(), size: 220)),
                  ],
                ),
              );
              final scoreCard = DarkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isKo ? '요인 점수' : 'Factor Scores',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < factorOrder.length; i += 1) ...[
                      _FactorRow(
                        factor: factorOrder[i],
                        value: scores.toMap()[factorOrder[i]] ?? 0,
                        isKo: isKo,
                      ),
                      if (i != factorOrder.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: chartCard),
                    const SizedBox(width: 16),
                    Expanded(child: scoreCard),
                  ],
                );
              }
              return Column(
                children: [
                  chartCard,
                  const SizedBox(height: 16),
                  scoreCard,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            isKo ? '추천 유형 TOP 5' : 'Top 5 Matches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          DarkCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var i = 0; i < matches.length; i += 1) ...[
                  _MatchRow(match: matches[i], isKo: isKo),
                  if (i != matches.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
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
          Row(
            children: [
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
              const SizedBox(width: 12),
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
            ],
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            onPressed: () => _shareSummary(isKo),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 18),
                const SizedBox(width: 8),
                Text(isKo ? '결과 공유' : 'Share Result'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DarkCard(
            padding: const EdgeInsets.all(12),
            color: AppColors.darkCard.withValues(alpha: 0.7),
            child: Row(
              children: [
                const Icon(Icons.info, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isKo
                        ? '결과는 참고용이며 전문 심리 진단을 대체하지 않습니다.'
                        : 'Results are for reference and do not replace professional assessment.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.gray400),
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

class _FactorRow extends StatelessWidget {
  final String factor;
  final double value;
  final bool isKo;

  const _FactorRow({
    required this.factor,
    required this.value,
    required this.isKo,
  });

  @override
  Widget build(BuildContext context) {
    final name = isKo ? factorNamesKo[factor] ?? '' : factorNamesEn[factor] ?? '';
    final color = factorColors[factor] ?? AppColors.purple500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              factor,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 6,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class _MatchRow extends StatelessWidget {
  final TypeMatch match;
  final bool isKo;

  const _MatchRow({required this.match, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final name = isKo ? match.profile.nameKo : match.profile.nameEn;
    final description = isKo ? match.profile.descriptionKo : match.profile.descriptionEn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                description,
                maxLines: 1,
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
