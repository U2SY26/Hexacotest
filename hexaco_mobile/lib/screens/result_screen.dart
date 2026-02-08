import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../data/data_repository.dart';
import '../models/score.dart';
import '../models/result_history.dart';
import '../services/recommendation_service.dart';
import '../services/history_service.dart';
import '../services/personality_analysis_service.dart';
import '../services/meme_content_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/gradient_text.dart';
import '../widgets/radar_chart.dart';
import '../widgets/ad_banner.dart';
import '../widgets/native_ad.dart';
import '../config/admob_ids.dart';
import '../services/rewarded_ad_service.dart';
import '../services/ai_analysis_service.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/save_prompt_dialog.dart';

class ResultScreen extends StatefulWidget {
  final TestController controller;
  final AppData data;
  final ResultHistoryEntry? savedEntry;

  const ResultScreen({
    super.key,
    required this.controller,
    required this.data,
    this.savedEntry,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late Scores scores;
  late List<TypeMatch> matches;
  bool _isLoading = true;
  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _celebrationController;
  AIAnalysisResult? _aiAnalysis;
  bool _aiLoading = false;

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

  bool get _isViewingSaved => widget.savedEntry != null;

  @override
  void initState() {
    super.initState();

    if (_isViewingSaved) {
      scores = Scores.fromMap(widget.savedEntry!.scores);
      matches = RecommendationService.topMatches(scores, widget.data.types, count: 5);
      _isLoading = false;
    } else {
      scores = widget.controller.calculateScores();
      matches = RecommendationService.topMatches(scores, widget.data.types, count: 5);
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (_isViewingSaved) {
      _fadeController.value = 1.0;
    } else {
      RewardedAdService.loadAd();
      _startLoadingAnimation();
    }
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

    // Show rewarded interstitial ad
    if (RewardedAdService.isAdReady) {
      await RewardedAdService.showAd(
        onAdDismissed: () {
          if (!mounted) return;
          _showResults();
        },
      );
    } else {
      _showResults();
    }
  }

  void _showResults() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _fadeController.forward();
    });
    _fetchAIAnalysis();
  }

  Future<void> _fetchAIAnalysis() async {
    setState(() => _aiLoading = true);
    final isKo = widget.controller.language == 'ko';
    // Detect country for non-Korean users
    String? country;
    if (!isKo) {
      final locale = Platform.localeName; // e.g. "en_US", "ja_JP"
      final parts = locale.split('_');
      country = parts.length > 1 ? parts[1] : 'international';
    }
    final result = await AIAnalysisService.fetchAnalysis(scores, isKo: isKo, country: country);
    if (mounted) {
      setState(() {
        _aiAnalysis = result;
        _aiLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _fadeController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _handleExitAttempt({String targetRoute = '/'}) async {
    if (_isViewingSaved) {
      Navigator.pop(context);
      return;
    }

    final isKo = widget.controller.language == 'ko';
    final wantsSave = await SavePromptDialog.show(context, isKo: isKo);

    if (wantsSave == null || !mounted) return;

    if (wantsSave) {
      final pin = await PinDialog.show(
        context,
        isKo: isKo,
        title: isKo ? 'PIN 설정' : 'Set PIN',
        subtitle: isKo ? '결과를 보호할 4자리 PIN을 입력하세요' : 'Enter a 4-digit PIN to protect your result',
      );
      if (pin == null || !mounted) return;

      final entry = ResultHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
        scores: scores.toMap(),
        topMatchId: matches.first.profile.id,
        similarity: matches.first.similarity,
        pin: pin,
        testVersion: widget.controller.testVersion,
      );
      await HistoryService.save(entry);
    }

    if (!mounted) return;
    widget.controller.reset();
    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
  }

  String _summaryText(bool isKo) {
    final topMatch = matches.first;
    final title = MemeContentService.getPersonalityTitle(scores);
    final mainMeme = MemeContentService.getMainMemeQuote(scores);
    final mbti = MemeContentService.getMBTIMatch(scores);

    return isKo
        ? '${title.emoji} ${title.titleKo}\n'
            '${mainMeme.emoji} ${mainMeme.quoteKo}\n\n'
            '🔮 MBTI 추정: ${mbti.mbti}\n'
            '👤 닮은 유명인: ${topMatch.profile.nameKo} (${topMatch.similarity}%)\n\n'
            '나도 테스트하기 👉 hexacotest.vercel.app'
        : '${title.emoji} ${title.titleEn}\n'
            '${mainMeme.emoji} ${mainMeme.quoteEn}\n\n'
            '🔮 MBTI guess: ${mbti.mbti}\n'
            '👤 Similar to: ${topMatch.profile.nameEn} (${topMatch.similarity}%)\n\n'
            'Try the test 👉 hexacotest.vercel.app';
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

  Future<void> _ilchoClipboardFallback(String jsonStr, bool isKo) async {
    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: jsonStr));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isKo
            ? '일초 앱에서 성격 프로필 > 가져오기에서 붙여넣기 하세요\n(일초 앱 최신 버전 필요)'
            : 'Paste in Ilcho app: Personality > Import\n(Latest Ilcho version required)'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _exportToIlcho(bool isKo) async {
    final topMatch = matches.isNotEmpty ? matches.first : null;
    final exportData = {
      'type': 'hexaco_export',
      'scores': {
        'H': scores.h,
        'E': scores.e,
        'X': scores.x,
        'A': scores.a,
        'C': scores.c,
        'O': scores.o,
      },
      'topMatch': topMatch?.profile.nameKo,
      'similarity': topMatch?.similarity,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final jsonStr = jsonEncode(exportData);
    final base64Data = base64Url.encode(utf8.encode(jsonStr));
    final uri = Uri.parse('ilcho://import?data=$base64Data');

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await _ilchoClipboardFallback(jsonStr, isKo);
      }
    } catch (e) {
      await _ilchoClipboardFallback(jsonStr, isKo);
    }
  }

  Future<void> _shareAsImage(bool isKo) async {
    // 공유할 카드 상세 선택 다이얼로그
    final selectedFactors = await showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) => _ShareSelectionDialog(
        scores: scores,
        isKo: isKo,
      ),
    );

    if (selectedFactors == null || !mounted) return;

    final shareKey = GlobalKey();

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.purple500),
        ),
      ),
    );

    // 오프스크린에서 공유 카드 렌더링 (Dialog 애니메이션 없이 캡처하여 이미지 반전 방지)
    final overlay = OverlayEntry(
      builder: (_) => Transform.translate(
        offset: const Offset(-10000, 0),
        child: RepaintBoundary(
          key: shareKey,
          child: _ShareCardContent(
            matches: matches,
            scores: scores,
            isKo: isKo,
            selectedFactors: selectedFactors,
            aiAnalysis: _aiAnalysis,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final boundary = shareKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        overlay.remove();
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      overlay.remove();

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
        text: _summaryText(isKo),
      );
    } catch (e) {
      overlay.remove();
      debugPrint('Share image error: $e');
      if (mounted) Navigator.of(context).pop();
      await Share.share(_summaryText(isKo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKo = widget.controller.language == 'ko';
    final topMatch = matches.first;
    if (_isLoading) {
      return _LoadingScreen(
        isKo: isKo,
        messageIndex: _loadingMessageIndex,
        messages: isKo ? _loadingMessagesKo : _loadingMessagesEn,
      );
    }

    return PopScope(
      canPop: _isViewingSaved,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleExitAttempt();
      },
      child: AppScaffold(
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
          // 밈 타이틀 카드
          _MemeHeaderCard(scores: scores, isKo: isKo),
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
          // HEXACO 6요인 분석 배너
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.purple500.withValues(alpha: 0.2)),
              gradient: LinearGradient(
                colors: [
                  AppColors.purple500.withValues(alpha: 0.08),
                  Colors.blue.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.purple500.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.hexagon_outlined, color: AppColors.purple500, size: 18),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKo ? 'HEXACO 6요인 분석' : 'HEXACO 6-Factor Analysis',
                        style: const TextStyle(
                          color: AppColors.purple500,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isKo
                            ? 'HEXACO는 MBTI와 달리 6가지 성격 요인의 강도를 0~100점으로 수치화하여, 자기 이해에 초점을 맞춘 과학적 분석입니다.'
                            : 'Unlike MBTI, HEXACO quantifies 6 personality factors on a 0–100 scale, providing a scientific analysis focused on self-understanding.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                              fontSize: 11,
                              height: 1.4,
                            ),
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
          // 밈 문구 & 캐릭터 매칭 섹션
          _MemeContentSection(scores: scores, isKo: isKo),
          const SizedBox(height: 16),
          _PersonalityAnalysisCard(scores: scores, isKo: isKo),
          const SizedBox(height: 16),
          _AIAnalysisCard(
            analysis: _aiAnalysis,
            isLoading: _aiLoading,
            isKo: isKo,
          ),
          const SizedBox(height: 16),
          // Matches: Korean → DB, Non-Korean → AI celebrities
          if (isKo || _aiAnalysis == null || _aiAnalysis!.celebrityMatches.isEmpty) ...[
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
          ] else ...[
            Text(
              'Famous Matches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Famous people with personalities similar to yours, suggested by AI',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray400,
                  ),
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
                  for (var i = 0; i < _aiAnalysis!.celebrityMatches.length; i += 1) ...[
                    _AICelebrityRow(celeb: _aiAnalysis!.celebrityMatches[i], rank: i + 1),
                    if (i != _aiAnalysis!.celebrityMatches.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
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
          const SizedBox(height: 16),
          const NativeAdWidget(),
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
              SecondaryButton(
                onPressed: () => _exportToIlcho(isKo),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.output, size: 18),
                    const SizedBox(width: 8),
                    Text(isKo ? '일초로 내보내기' : 'Export to Ilcho'),
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
                  onPressed: () => _handleExitAttempt(targetRoute: '/test'),
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
                  onPressed: () => _handleExitAttempt(),
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

class _PersonalityAnalysisCard extends StatelessWidget {
  final Scores scores;
  final bool isKo;

  const _PersonalityAnalysisCard({required this.scores, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final analyses = PersonalityAnalysisService.getFactorAnalyses(scores, isKo);
    final overallAnalysis = PersonalityAnalysisService.getOverallAnalysis(scores, isKo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo ? '성격 분석 리포트' : 'Personality Analysis Report',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  isKo ? '카드를 탭하여 상세 분석을 확인하세요' : 'Tap cards to see detailed analysis',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray400,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 6개 요인 플립 카드 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isKo ? 0.85 : 0.75,
          ),
          itemCount: analyses.length,
          itemBuilder: (context, index) {
            return _FlipFactorCard(
              analysis: analyses[index],
              isKo: isKo,
            );
          },
        ),

        const SizedBox(height: 20),

        // 종합 분석 카드
        DarkCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purple500, AppColors.pink500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isKo ? '종합 분석' : 'Overall Analysis',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                overallAnalysis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray300,
                      height: 1.7,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// AI 심리 분석 리포트 카드
class _AIAnalysisCard extends StatefulWidget {
  final AIAnalysisResult? analysis;
  final bool isLoading;
  final bool isKo;

  const _AIAnalysisCard({
    required this.analysis,
    required this.isLoading,
    required this.isKo,
  });

  @override
  State<_AIAnalysisCard> createState() => _AIAnalysisCardState();
}

class _AIAnalysisCardState extends State<_AIAnalysisCard> {
  final Set<String> _expandedFactors = {};

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isKo ? 'AI 심리 분석 리포트' : 'AI Psychology Report',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.isKo
                          ? 'AI가 당신의 성격을 깊이 분석하고 있어요...'
                          : 'AI is deeply analyzing your personality...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray400,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else if (widget.analysis == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  widget.isKo ? 'AI 분석을 불러올 수 없었습니다.' : 'Could not load AI analysis.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray500,
                      ),
                ),
              ),
            )
          else ...[
            Text(
              widget.analysis!.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray300,
                    height: 1.7,
                  ),
            ),
            if (widget.analysis!.factors.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.analysis!.factors.map((af) {
                final color = factorColors[af.factor] ?? AppColors.purple500;
                final expanded = _expandedFactors.contains(af.factor);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                      gradient: LinearGradient(
                        colors: [color.withValues(alpha: 0.06), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (expanded) {
                                _expandedFactors.remove(af.factor);
                              } else {
                                _expandedFactors.add(af.factor);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Text(
                                  af.factor,
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.isKo
                                        ? (factorNamesKo[af.factor] ?? af.factor)
                                        : (factorNamesEn[af.factor] ?? af.factor),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.gray400,
                                        ),
                                  ),
                                ),
                                Icon(
                                  expanded ? Icons.expand_less : Icons.expand_more,
                                  color: AppColors.gray500,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (expanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  af.overview,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.gray300,
                                        height: 1.6,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.isKo ? '강점' : 'Strengths',
                                  style: TextStyle(
                                    color: AppColors.emerald500,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...af.strengths.map((s) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('+ ',
                                              style: TextStyle(
                                                  color: AppColors.emerald500, fontSize: 12)),
                                          Expanded(
                                            child: Text(s,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: AppColors.gray400, height: 1.4)),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  widget.isKo ? '성장 포인트' : 'Growth Areas',
                                  style: const TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...af.risks.map((r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('~ ',
                                              style: TextStyle(
                                                  color: Color(0xFFFBBF24), fontSize: 12)),
                                          Expanded(
                                            child: Text(r,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: AppColors.gray400, height: 1.4)),
                                          ),
                                        ],
                                      ),
                                    )),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    af.growth,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF93C5FD),
                                          height: 1.5,
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
              }),
            ],
            // 나와 잘 맞는 MBTI
            if (widget.analysis!.compatibleMBTIs.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.darkBorder)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💕', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          widget.isKo ? '나와 잘 맞는 MBTI' : 'Compatible MBTI Types',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: widget.analysis!.compatibleMBTIs.map((cm) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.pink500.withValues(alpha: 0.1),
                                    AppColors.purple500.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.pink500.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    cm.mbti,
                                    style: const TextStyle(
                                      color: AppColors.pink500,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cm.reason,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.gray400,
                                          fontSize: 10,
                                          height: 1.3,
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
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

// 플립 카드 위젯
class _FlipFactorCard extends StatefulWidget {
  final FactorAnalysis analysis;
  final bool isKo;

  const _FlipFactorCard({
    required this.analysis,
    required this.isKo,
  });

  @override
  State<_FlipFactorCard> createState() => _FlipFactorCardState();
}

class _FlipFactorCardState extends State<_FlipFactorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = factorColors[widget.analysis.factor] ?? AppColors.purple500;
    final name = widget.isKo ? widget.analysis.nameKo : widget.analysis.nameEn;
    final summary = widget.isKo ? widget.analysis.summaryKo : widget.analysis.summaryEn;
    final detail = widget.isKo ? widget.analysis.detailKo : widget.analysis.detailEn;

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final isFront = angle < 1.5708;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _buildFrontCard(color, name, summary)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildBackCard(color, name, detail),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard(Color color, String name, String summary) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            AppColors.darkCard,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.analysis.factor,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.analysis.score.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: widget.analysis.score / 100,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                widget.analysis.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray300,
                        height: 1.3,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app,
                size: 14,
                color: color.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                widget.isKo ? '탭하여 자세히 보기' : 'Tap for details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(Color color, String name, String detail) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCard,
            color.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.analysis.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${widget.analysis.factor} - $name',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                detail,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray300,
                      height: 1.5,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 14,
                  color: color.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.isKo ? '탭하여 돌아가기' : 'Tap to flip back',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 11,
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

class _AICelebrityRow extends StatelessWidget {
  final AICelebrityMatch celeb;
  final int rank;

  const _AICelebrityRow({required this.celeb, required this.rank});

  @override
  Widget build(BuildContext context) {
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
              celeb.name.characters.first,
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
                      celeb.name,
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
                celeb.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${celeb.similarity}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.purple400),
        ),
      ],
    );
  }
}

class _ShareSelectionDialog extends StatefulWidget {
  final Scores scores;
  final bool isKo;

  const _ShareSelectionDialog({
    required this.scores,
    required this.isKo,
  });

  @override
  State<_ShareSelectionDialog> createState() => _ShareSelectionDialogState();
}

class _ShareSelectionDialogState extends State<_ShareSelectionDialog> {
  final Set<String> _selected = {};

  void _toggleAll() {
    setState(() {
      if (_selected.length == factorOrder.length) {
        _selected.clear();
      } else {
        _selected.addAll(factorOrder);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyses = PersonalityAnalysisService.getFactorAnalyses(widget.scores, widget.isKo);

    return Dialog(
      backgroundColor: const Color(0xFF1A1035),
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.purple500.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.share, color: AppColors.purple400, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isKo ? '이미지 공유' : 'Share Image',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _toggleAll,
                  child: Text(
                    _selected.length == factorOrder.length
                        ? (widget.isKo ? '전체 해제' : 'Deselect All')
                        : (widget.isKo ? '전체 선택' : 'Select All'),
                    style: const TextStyle(color: AppColors.purple400, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.isKo
                  ? '포함할 성격 분석 카드를 선택하세요'
                  : 'Select personality cards to include',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gray400,
                  ),
            ),
            const SizedBox(height: 16),
            ...analyses.map((analysis) {
              final color = factorColors[analysis.factor] ?? AppColors.purple500;
              final isSelected = _selected.contains(analysis.factor);
              final name = widget.isKo ? analysis.nameKo : analysis.nameEn;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(analysis.factor);
                      } else {
                        _selected.add(analysis.factor);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color.withValues(alpha: 0.6)
                            : AppColors.darkBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected ? color : color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              analysis.factor,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name ${analysis.emoji}',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.gray300,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${analysis.score.toStringAsFixed(0)}% — ${widget.isKo ? analysis.summaryKo : analysis.summaryEn}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.gray500,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? color : AppColors.gray600,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(
                      widget.isKo ? '취소' : 'Cancel',
                      style: const TextStyle(color: AppColors.gray400),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _selected.isEmpty
                              ? (widget.isKo ? '기본 이미지 공유' : 'Share Basic Image')
                              : (widget.isKo
                                  ? '${_selected.length}개 카드 포함 공유'
                                  : 'Share with ${_selected.length} cards'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareCardContent extends StatelessWidget {
  final List<TypeMatch> matches;
  final Scores scores;
  final bool isKo;
  final Set<String> selectedFactors;
  final AIAnalysisResult? aiAnalysis;

  const _ShareCardContent({
    required this.matches,
    required this.scores,
    required this.isKo,
    required this.selectedFactors,
    this.aiAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final topMatch = matches.first;
    final title = MemeContentService.getPersonalityTitle(scores);
    final mainMeme = MemeContentService.getMainMemeQuote(scores);
    final mbti = MemeContentService.getMBTIMatch(scores);
    final character = MemeContentService.getCharacterMatch(scores);

    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
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
          // HEXACO 로고
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hexagon, color: AppColors.purple500, size: 24),
              const SizedBox(width: 6),
              Text(
                'HEXACO',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 메인 타이틀 (밈)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple500, AppColors.pink500],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isKo ? title.titleKo : title.titleEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 대표 밈 문구
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkCard.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple500.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainMeme.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    isKo ? mainMeme.quoteKo : mainMeme.quoteEn,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray300,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // MBTI + 캐릭터 매칭 (가로 배치)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text('🔮', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        mbti.mbti,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.pink500,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        isKo ? mbti.descriptionKo : mbti.descriptionEn,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                              fontSize: 10,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(character.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        isKo ? character.nameKo : character.nameEn,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.purple400,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        character.source,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray500,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 닮은 유명인
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purple500.withValues(alpha: 0.2),
                  AppColors.pink500.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn)
                          .characters
                          .first,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isKo ? '닮은 유명인' : 'Similar Celebrity',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                              fontSize: 10,
                            ),
                      ),
                      Text(
                        isKo ? topMatch.profile.nameKo : topMatch.profile.nameEn,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.purple500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${topMatch.similarity}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 선택한 요인 상세 카드 (반응형 그리드)
          if (selectedFactors.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                isKo ? '성격 분석 상세' : 'Personality Details',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray400,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
            ),
            Builder(builder: (context) {
              final items = PersonalityAnalysisService.getFactorAnalyses(scores, isKo)
                  .where((a) => selectedFactors.contains(a.factor))
                  .toList();
              // 반응형 너비: 1~2개면 2열, 3개이상 3열
              final cols = items.length <= 2 ? 2 : 3;
              final cardWidth = (310 - (cols - 1) * 6) / cols;
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: items.map((analysis) {
                  final color = factorColors[analysis.factor] ?? AppColors.purple500;
                  final name = isKo ? analysis.nameKo : analysis.nameEn;
                  final summary = isKo ? analysis.summaryKo : analysis.summaryEn;

                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.darkCard,
                            color.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    analysis.factor,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${analysis.score.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$name ${analysis.emoji}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                              height: 4,
                              child: LinearProgressIndicator(
                                value: analysis.score / 100,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray400,
                                  fontSize: 7,
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 4),
          ],

          // AI 심리분석 결과
          if (aiAnalysis != null && selectedFactors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    isKo ? 'AI 심리분석' : 'AI Psychology Report',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.purple400,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // AI 요약
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.purple500.withValues(alpha: 0.2)),
              ),
              child: Text(
                aiAnalysis!.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.gray300,
                      fontSize: 9,
                      height: 1.4,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            // 요인별 AI 분석
            ...aiAnalysis!.factors
                .where((f) => selectedFactors.contains(f.factor))
                .map((af) {
              final color = factorColors[af.factor] ?? AppColors.purple500;
              final factorName = isKo
                  ? const {'H': '정직-겸손', 'E': '정서성', 'X': '외향성', 'A': '원만성', 'C': '성실성', 'O': '개방성'}[af.factor] ?? af.factor
                  : const {'H': 'Honesty-Humility', 'E': 'Emotionality', 'X': 'Extraversion', 'A': 'Agreeableness', 'C': 'Conscientiousness', 'O': 'Openness'}[af.factor] ?? af.factor;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.darkCard,
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 요인 헤더
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                af.factor,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            factorName,
                            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 개요
                      Text(
                        af.overview,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.gray300,
                              fontSize: 8,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 6),
                      // 강점
                      ...af.strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('+ ', style: TextStyle(color: Colors.green[400], fontSize: 8, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(s, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400, fontSize: 8, height: 1.3))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 4),
                      // 성장 포인트
                      ...af.risks.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('~ ', style: TextStyle(color: Colors.amber[400], fontSize: 8, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(r, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400, fontSize: 8, height: 1.3))),
                          ],
                        ),
                      )),
                      const SizedBox(height: 4),
                      // 성장 조언
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('💡 ', style: TextStyle(fontSize: 8)),
                          Expanded(child: Text(af.growth, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.purple400, fontSize: 8, height: 1.3))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            // 나와 잘 맞는 MBTI (공유 이미지)
            if (aiAnalysis!.compatibleMBTIs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💕', style: TextStyle(fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(
                    isKo ? '잘 맞는 MBTI' : 'Compatible MBTIs',
                    style: TextStyle(color: AppColors.pink500, fontWeight: FontWeight.w700, fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: aiAnalysis!.compatibleMBTIs.map((cm) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.pink500.withValues(alpha: 0.15),
                            AppColors.purple500.withValues(alpha: 0.15),
                          ]),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.pink500.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(cm.mbti, style: const TextStyle(color: AppColors.pink500, fontWeight: FontWeight.w900, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(cm.reason, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: AppColors.gray400, fontSize: 6, height: 1.2)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],

          // 웹사이트 링크
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
    );
  }
}

// 밈 헤더 카드 (타이틀 + 대표 밈 문구)
class _MemeHeaderCard extends StatelessWidget {
  final Scores scores;
  final bool isKo;

  const _MemeHeaderCard({required this.scores, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final title = MemeContentService.getPersonalityTitle(scores);
    final mainMeme = MemeContentService.getMainMemeQuote(scores);

    return DarkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 메인 타이틀
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.purple500, AppColors.pink500],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple500.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    isKo ? title.titleKo : title.titleEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 타이틀 설명
          Text(
            isKo ? title.descriptionKo : title.descriptionEn,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray300,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 대표 밈 문구
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purple500.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mainMeme.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    isKo ? mainMeme.quoteKo : mainMeme.quoteEn,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray300,
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
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

// 밈 콘텐츠 섹션 (밈 문구들 + 캐릭터 매칭 + MBTI)
class _MemeContentSection extends StatelessWidget {
  final Scores scores;
  final bool isKo;

  const _MemeContentSection({required this.scores, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final memeQuotes = MemeContentService.getMemeQuotes(scores);
    final character = MemeContentService.getCharacterMatch(scores);
    final mbti = MemeContentService.getMBTIMatch(scores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.pink500, AppColors.purple500],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKo ? '나를 표현하는 한 줄' : 'One-liner About Me',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  isKo ? '공유하면 친구들이 공감할 거예요!' : 'Share and friends will relate!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray400,
                      ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 밈 문구 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
          ),
          itemCount: memeQuotes.length,
          itemBuilder: (context, index) {
            final quote = memeQuotes[index];
            final color = factorColors[quote.factor] ?? AppColors.purple500;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.2),
                    AppColors.darkCard,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quote.factor,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        quote.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      isKo ? quote.quoteKo : quote.quoteEn,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray300,
                            height: 1.3,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // 캐릭터 매칭 + MBTI 섹션
        Row(
          children: [
            // 드라마/영화 캐릭터 매칭
            Expanded(
              child: DarkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          character.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isKo ? '닮은 캐릭터' : 'Similar Character',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray400,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isKo ? character.nameKo : character.nameEn,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.purple400,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.source,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray500,
                            fontSize: 11,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isKo ? character.reasonKo : character.reasonEn,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray400,
                            fontSize: 11,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // MBTI 추정
            Expanded(
              child: DarkCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isKo ? '참고용' : 'Ref',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('🔮', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isKo ? 'MBTI 추정' : 'MBTI Est.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.gray400,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mbti.mbti,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.pink500,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isKo ? mbti.descriptionKo : mbti.descriptionEn,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray400,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isKo
                          ? '※ HEXACO 기반 추정이며, 핵심은 6요인 분석입니다'
                          : '※ Estimated from HEXACO. Core analysis is the 6 factors.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.gray600,
                            fontSize: 9,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

