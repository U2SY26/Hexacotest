import 'package:flutter/material.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../data/data_repository.dart';
import '../models/score.dart';
import '../services/recommendation_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/ad_banner.dart';
import '../config/admob_ids.dart';
import '../widgets/radar_chart.dart';

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

  @override
  void initState() {
    super.initState();
    scores = widget.controller.calculateScores();
    matches = RecommendationService.topMatches(scores, widget.data.types, count: 5);
  }

  @override
  Widget build(BuildContext context) {
    final isKo = widget.controller.language == 'ko';
    final topMatch = matches.first;

    return AppScaffold(
      appBar: AppHeader(controller: widget.controller),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            isKo ? '결과 분석' : 'Your Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            isKo
                ? '100가지 유형 중 가장 가까운 유형을 추천합니다.'
                : 'We recommend the closest matches among 100 types.',
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
                  isKo ? '나의 HEXACO 프로필' : 'My HEXACO Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Center(child: RadarChart(scores: scores.toMap(), size: 260)),
                const SizedBox(height: 12),
                Text(
                  isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  isKo ? topMatch.profile.descriptionKo : topMatch.profile.descriptionEn,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray400),
                ),
                const SizedBox(height: 10),
                Text(
                  isKo ? '유사도 ${topMatch.similarity}%' : 'Similarity ${topMatch.similarity}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.purple400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isKo ? '요인 점수' : 'Factor Scores',
            style: Theme.of(context).textTheme.titleMedium,
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
          const SizedBox(height: 20),
          Text(
            isKo ? '추천 유형 TOP 5' : 'Top 5 Matches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Column(
            children: matches.map((match) {
              final initials = (isKo ? match.profile.nameKo : match.profile.nameEn).characters.first;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DarkCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKo ? match.profile.nameKo : match.profile.nameEn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isKo ? match.profile.descriptionKo : match.profile.descriptionEn,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.gray400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${match.similarity}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.purple400),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
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
