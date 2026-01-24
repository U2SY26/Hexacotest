import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _shareSummary(bool isKo) async {
    await Share.share(_summaryText(isKo));
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray400),
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
                      Text(
                        isKo ? '유사도 ${topMatch.similarity}%' : 'Similarity ${topMatch.similarity}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.purple400),
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
          DarkCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo ? 'AI 성격 분석 (준비중)' : 'AI Personality Analysis (Coming soon)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isKo
                      ? '현재 AI 기능은 비활성화되어 있습니다. 기본 결과만 제공합니다.'
                      : 'AI analysis is disabled for now. Showing core results only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          ),
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
                onPressed: () => _shareSummary(isKo),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share, size: 18),
                    const SizedBox(width: 8),
                    Text(isKo ? '결과 공유' : 'Share Result'),
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
            child: Row(
              children: [
                const Icon(Icons.info, size: 16, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isKo
                        ? '결과는 참고용이며 전문 심리 진단을 대체하지 않습니다.'
                        : 'Results are for reference and do not replace professional assessment.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
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
