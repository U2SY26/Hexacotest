import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../models/question.dart';
import '../services/rewarded_ad_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';
import '../widgets/ad_banner.dart';
import '../widgets/native_ad.dart';
import '../config/admob_ids.dart';

class TestScreen extends StatefulWidget {
  final TestController controller;

  const TestScreen({super.key, required this.controller});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  /// How often (in questions) to show an interstitial ad.
  static const int _adInterval = 15;

  TestController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // Preload the first interstitial ad so it is ready by question 15.
    RewardedAdService.loadAd();
  }

  void _showResultPopup(BuildContext context, bool isKo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultPopupDialog(isKo: isKo),
    );
  }

  /// Returns true when an interstitial ad should be shown before advancing.
  /// Fires at questions 15, 30, 45, ... (1-based) and never on the last question.
  bool _shouldShowAd() {
    final nextIndex = controller.currentIndex + 1; // 1-based question number
    final isLast = controller.currentIndex == controller.questions.length - 1;
    return !isLast && nextIndex % _adInterval == 0;
  }

  /// Advance to the next question, optionally showing an interstitial ad first.
  void _handleNext(BuildContext context, bool isKo, int? currentAnswer) {
    final isLast = controller.currentIndex == controller.questions.length - 1;

    if (isLast && controller.isComplete) {
      _showResultPopup(context, isKo);
      return;
    }

    if (currentAnswer == null) return;

    if (_shouldShowAd()) {
      _showAdBreakDialog(context, isKo);
    } else {
      controller.next();
    }
  }

  void _showAdBreakDialog(BuildContext context, bool isKo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => _AdBreakDialog(
        isKo: isKo,
        onContinue: () {
          Navigator.of(ctx).pop();
          controller.next();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final isKo = controller.language == 'ko';
        final questions = controller.questions;
        final question = controller.currentQuestion;
        final currentAnswer = controller.getAnswer(question.id);
        final isLast = controller.currentIndex == questions.length - 1;

        void handleNext() {
          _handleNext(context, isKo, currentAnswer);
        }

        return AppScaffold(
          scroll: false,
          stickyBanner: BannerAdSection(adUnitId: bannerAdUnitId),
          child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.arrowUp): _NavigateIntent(-1),
              LogicalKeySet(LogicalKeyboardKey.arrowDown): _NavigateIntent(1),
              LogicalKeySet(LogicalKeyboardKey.enter): _NavigateIntent(1),
              LogicalKeySet(LogicalKeyboardKey.space): _NavigateIntent(1),
            },
            child: Actions(
              actions: {
                _NavigateIntent: CallbackAction<_NavigateIntent>(
                  onInvoke: (intent) {
                    if (intent.delta > 0) {
                      handleNext();
                    } else if (controller.currentIndex > 0) {
                      controller.prev();
                    }
                    return null;
                  },
                ),
              },
              child: Focus(
                autofocus: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProgressIndicator(
                      currentIndex: controller.currentIndex,
                      total: questions.length,
                      progress: controller.progress,
                      factor: question.factor,
                      isKo: isKo,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 작은 화면에서는 스크롤 가능하게
                          final isSmallScreen = constraints.maxHeight < 400;

                          final content = Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _QuestionCard(
                                question: question,
                                isKo: isKo,
                                index: controller.currentIndex + 1,
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              _PercentageSlider(
                                isKo: isKo,
                                factor: question.factor,
                                currentAnswer: currentAnswer,
                                onSelect: (value) => controller.setAnswer(question.id, value),
                                compact: isSmallScreen,
                              ),
                            ],
                          );

                          if (isSmallScreen) {
                            return SingleChildScrollView(
                              child: content,
                            );
                          }

                          return Column(
                            children: [
                              _QuestionCard(
                                question: question,
                                isKo: isKo,
                                index: controller.currentIndex + 1,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Center(
                                  child: _PercentageSlider(
                                    isKo: isKo,
                                    factor: question.factor,
                                    currentAnswer: currentAnswer,
                                    onSelect: (value) => controller.setAnswer(question.id, value),
                                    compact: false,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            onPressed: controller.currentIndex == 0 ? null : controller.prev,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Text(
                              isKo ? '이전' : 'Prev',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: currentAnswer == null ? null : handleNext,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            child: Text(
                              isLast ? (isKo ? '완료' : 'Finish') : (isKo ? '다음' : 'Next'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        isKo
                            ? '슬라이더를 드래그하여 동의 정도를 선택하세요.'
                            : 'Drag the slider to select your agreement level.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.gray500, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 15문항마다 표시되는 쉬어가기 다이얼로그 (보상형 광고 포함)
class _AdBreakDialog extends StatefulWidget {
  final bool isKo;
  final VoidCallback onContinue;

  const _AdBreakDialog({required this.isKo, required this.onContinue});

  @override
  State<_AdBreakDialog> createState() => _AdBreakDialogState();
}

class _AdBreakDialogState extends State<_AdBreakDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _canContinue = true);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1035), Color(0xFF2D1B4E)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.purple500.withAlpha(77)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 커피 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple500, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple500.withAlpha(77),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isKo ? '잠시 쉬어가세요' : 'Take a Short Break',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isKo
                  ? '잠시 눈을 쉬고, 다음 질문을 준비해보세요.'
                  : 'Rest your eyes for a moment before continuing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(102),
              ),
            ),
            const SizedBox(height: 16),
            // 네이티브 광고
            const NativeAdWidget(),
            const SizedBox(height: 16),
            // 3초 로딩바 + 계속하기 버튼
            if (_canContinue)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.purple500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.isKo ? '계속하기' : 'Continue',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // 3초 프로그레스 바
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 6,
                          backgroundColor: AppColors.darkBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.purple500,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isKo ? '잠시만 기다려주세요...' : 'Please wait...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withAlpha(77),
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

class _NavigateIntent extends Intent {
  final int delta;
  const _NavigateIntent(this.delta);
}

class _ProgressIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final double progress;
  final String factor;
  final bool isKo;

  const _ProgressIndicator({
    required this.currentIndex,
    required this.total,
    required this.progress,
    required this.factor,
    required this.isKo,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    final accent = factorColors[factor] ?? AppColors.purple500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isKo ? '질문 ${currentIndex + 1} / $total' : 'Question ${currentIndex + 1} / $total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth * progress)
                .clamp(0.0, constraints.maxWidth)
                .toDouble();
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 8,
                  width: width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.purple500, accent],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: factorOrder.map((f) {
            final active = f == factor;
            final color = factorColors[f] ?? Colors.white;
            return AnimatedScale(
              scale: active ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active ? color : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      color: active ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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

class _QuestionCard extends StatelessWidget {
  final Question question;
  final bool isKo;
  final int index;

  const _QuestionCard({
    required this.question,
    required this.isKo,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = factorColors[question.factor] ?? AppColors.purple500;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.xl),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
          ),
        ),
        DarkCard(
          padding: const EdgeInsets.all(20),
          radius: AppRadii.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      question.factor,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isKo ? '질문 $index' : 'Question $index',
                      style: TextStyle(color: color),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isKo ? question.ko : question.en,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4),
              ),
              if ((isKo ? question.koExample : question.enExample) != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: color.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isKo ? question.koExample! : question.enExample!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.gray400,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PercentageSlider extends StatefulWidget {
  final bool isKo;
  final String factor;
  final int? currentAnswer;
  final ValueChanged<int> onSelect;
  final bool compact;

  const _PercentageSlider({
    required this.isKo,
    required this.factor,
    required this.currentAnswer,
    required this.onSelect,
    this.compact = false,
  });

  @override
  State<_PercentageSlider> createState() => _PercentageSliderState();
}

class _PercentageSliderState extends State<_PercentageSlider>
    with SingleTickerProviderStateMixin {
  // Internal position: -100 (left/agree) to +100 (right/disagree)
  double _sliderPosition = 0;
  bool _isDragging = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    // Set initial answer as neutral (50 = 0%) so next button is enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.currentAnswer == null) {
        widget.onSelect(_storageValue); // 50 (neutral)
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PercentageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset slider when question changes (currentAnswer becomes null)
    if (widget.currentAnswer == null && oldWidget.currentAnswer != null) {
      setState(() {
        _sliderPosition = 0;
      });
      // Auto-set neutral answer so next button is enabled
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelect(_storageValue); // 50 (neutral)
      });
    }
    // Restore slider position if question has existing answer
    if (widget.currentAnswer != null && oldWidget.currentAnswer != widget.currentAnswer) {
      setState(() {
        // Convert storage value back to slider position
        // storage 0-100 → slider -100 to +100
        _sliderPosition = (100 - widget.currentAnswer! * 2).toDouble();
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // Convert slider position to score: left(-100)=100, center(0)=50, right(+100)=0
  int get _storageValue => ((100 - _sliderPosition) / 2).round().clamp(0, 100);
  bool get _isLeftSide => _sliderPosition < 0;
  bool get _isRightSide => _sliderPosition > 0;

  Color _getPositionColor() {
    final percentage = _sliderPosition.abs() / 100;
    if (_sliderPosition == 0) {
      return AppColors.gray500;
    } else if (_isLeftSide) {
      // Agree side - purple to pink (warm)
      return Color.lerp(AppColors.purple500, AppColors.pink500, percentage) ?? AppColors.purple500;
    } else {
      // Disagree side - blue to cyan (cool)
      return Color.lerp(AppColors.blue500, AppColors.cyan500, percentage) ?? AppColors.blue500;
    }
  }

  void _handleTap(double localX, double trackWidth) {
    final center = trackWidth / 2;
    final offset = localX - center;
    final normalized = (offset / (trackWidth / 2)).clamp(-1.0, 1.0);
    setState(() {
      _sliderPosition = (normalized * 100).roundToDouble();
    });
    widget.onSelect(_storageValue);
    HapticFeedback.lightImpact();
  }

  void _handleDragUpdate(double localX, double trackWidth) {
    final center = trackWidth / 2;
    final offset = localX - center;
    final normalized = (offset / (trackWidth / 2)).clamp(-1.0, 1.0);
    final newPosition = (normalized * 100).roundToDouble();

    // Haptic feedback at 25% increments
    final oldQuarter = (_sliderPosition.abs() / 25).floor();
    final newQuarter = (newPosition.abs() / 25).floor();
    if (oldQuarter != newQuarter) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _sliderPosition = newPosition;
    });
  }

  void _handleDragEnd() {
    setState(() {
      _isDragging = false;
    });
    widget.onSelect(_storageValue);
    if (_sliderPosition.abs() >= 90) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final agreeLabel = widget.isKo ? sliderLabelsKo['agree']! : sliderLabelsEn['agree']!;
    final disagreeLabel = widget.isKo ? sliderLabelsKo['disagree']! : sliderLabelsEn['disagree']!;
    final neutralLabel = widget.isKo ? sliderLabelsKo['neutral']! : sliderLabelsEn['neutral']!;
    final positionColor = _getPositionColor();
    final percentage = _sliderPosition.abs().round();
    final compact = widget.compact;

    return Column(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Percentage display
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 24,
                vertical: compact ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(
                  color: positionColor.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: percentage > 50
                    ? [
                        BoxShadow(
                          color: positionColor.withValues(alpha: _glowAnimation.value * 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sliderPosition == 0
                        ? Icons.radio_button_unchecked
                        : Icons.circle,
                    color: positionColor,
                    size: compact ? 16 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: (compact
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.headlineSmall)
                        ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: compact ? 10 : 16),

        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  agreeLabel,
                  style: TextStyle(
                    color: _isLeftSide ? AppColors.purple400 : AppColors.gray500,
                    fontWeight: _isLeftSide ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                neutralLabel,
                style: TextStyle(
                  color: _sliderPosition == 0 ? Colors.white : AppColors.gray500,
                  fontWeight: _sliderPosition == 0 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Text(
                  disagreeLabel,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: _isRightSide ? AppColors.cyan500 : AppColors.gray500,
                    fontWeight: _isRightSide ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Slider track
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28), // 원이 잘리지 않도록 패딩 증가
          child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final thumbPosition = (trackWidth / 2) + (_sliderPosition / 100 * trackWidth / 2);

            return GestureDetector(
              onTapDown: (details) => _handleTap(details.localPosition.dx, trackWidth),
              onPanStart: (_) => setState(() => _isDragging = true),
              onPanUpdate: (details) => _handleDragUpdate(details.localPosition.dx, trackWidth),
              onPanEnd: (_) => _handleDragEnd(),
              child: Container(
                height: compact ? 56 : 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Track background with neutral gradient
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.purple500,
                            AppColors.pink500,
                            AppColors.gray600,
                            AppColors.blue500,
                            AppColors.cyan500,
                          ],
                          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.darkBg.withValues(alpha: 0.6),
                        ),
                      ),
                    ),

                    // Active fill from center
                    Positioned(
                      left: _isLeftSide ? thumbPosition : trackWidth / 2,
                      right: _isRightSide ? trackWidth - thumbPosition : trackWidth / 2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: _isLeftSide
                                ? [AppColors.purple500, AppColors.pink500]
                                : [AppColors.blue500, AppColors.cyan500],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: positionColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center marker
                    Positioned(
                      left: trackWidth / 2 - 2,
                      child: Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tick marks at 25%, 50%, 75%
                    ...[-75, -50, -25, 25, 50, 75].map((tick) {
                      final tickX = trackWidth / 2 + (tick / 100 * trackWidth / 2);
                      return Positioned(
                        left: tickX - 1,
                        child: Container(
                          width: 2,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.gray500.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),

                    // Thumb
                    AnimatedPositioned(
                      duration: Duration(milliseconds: _isDragging ? 0 : 150),
                      curve: Curves.easeOut,
                      left: thumbPosition - 20,
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  positionColor,
                                  positionColor.withValues(alpha: 0.8),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: positionColor.withValues(
                                    alpha: percentage > 50 ? _glowAnimation.value * 0.6 : 0.3,
                                  ),
                                  blurRadius: percentage > 50 ? 20 : 10,
                                  spreadRadius: percentage > 50 ? 4 : 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$percentage',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),

        if (!compact) ...[
          const SizedBox(height: 8),

          // 100% labels at ends
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '100%',
                  style: TextStyle(
                    color: _isLeftSide && percentage > 80 ? AppColors.purple400 : AppColors.gray600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '0%',
                  style: TextStyle(
                    color: _sliderPosition == 0 ? Colors.white : AppColors.gray600,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    color: _isRightSide && percentage > 80 ? AppColors.cyan500 : AppColors.gray600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultPopupDialog extends StatefulWidget {
  final bool isKo;

  const _ResultPopupDialog({required this.isKo});

  @override
  State<_ResultPopupDialog> createState() => _ResultPopupDialogState();
}

class _ResultPopupDialogState extends State<_ResultPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.purple500, AppColors.pink500],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple500.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isKo ? '테스트 완료!' : 'Test Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isKo
                  ? '당신의 성격 분석 결과가 준비되었습니다.'
                  : 'Your personality analysis is ready.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray400,
                  ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple500.withValues(alpha: _glowAnimation.value * 0.6),
                          blurRadius: 20 + (_glowAnimation.value * 15),
                          spreadRadius: _glowAnimation.value * 5,
                        ),
                        BoxShadow(
                          color: AppColors.pink500.withValues(alpha: _glowAnimation.value * 0.4),
                          blurRadius: 30 + (_glowAnimation.value * 20),
                          spreadRadius: _glowAnimation.value * 3,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.pushNamed(context, '/result');
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.purple500, AppColors.pink500],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: _glowAnimation.value * 0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                widget.isKo ? '결과 보기' : 'View Results',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
