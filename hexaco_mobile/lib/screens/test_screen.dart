import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';
import '../controllers/test_controller.dart';
import '../models/question.dart';
import '../ui/app_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/buttons.dart';
import '../widgets/dark_card.dart';

class TestScreen extends StatelessWidget {
  final TestController controller;

  const TestScreen({super.key, required this.controller});

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
          if (isLast && controller.isComplete) {
            Navigator.pushNamed(context, '/result');
          } else if (currentAnswer != null) {
            controller.next();
          }
        }

        return AppScaffold(
          appBar: AppHeader(controller: controller),
          scroll: false,
          child: Shortcuts(
            shortcuts: {
              LogicalKeySet(LogicalKeyboardKey.digit1): _AnswerIntent(1),
              LogicalKeySet(LogicalKeyboardKey.digit2): _AnswerIntent(2),
              LogicalKeySet(LogicalKeyboardKey.digit3): _AnswerIntent(3),
              LogicalKeySet(LogicalKeyboardKey.digit4): _AnswerIntent(4),
              LogicalKeySet(LogicalKeyboardKey.digit5): _AnswerIntent(5),
              LogicalKeySet(LogicalKeyboardKey.numpad1): _AnswerIntent(1),
              LogicalKeySet(LogicalKeyboardKey.numpad2): _AnswerIntent(2),
              LogicalKeySet(LogicalKeyboardKey.numpad3): _AnswerIntent(3),
              LogicalKeySet(LogicalKeyboardKey.numpad4): _AnswerIntent(4),
              LogicalKeySet(LogicalKeyboardKey.numpad5): _AnswerIntent(5),
              LogicalKeySet(LogicalKeyboardKey.arrowRight): _NavigateIntent(1),
              LogicalKeySet(LogicalKeyboardKey.arrowLeft): _NavigateIntent(-1),
              LogicalKeySet(LogicalKeyboardKey.enter): _NavigateIntent(1),
              LogicalKeySet(LogicalKeyboardKey.space): _NavigateIntent(1),
            },
            child: Actions(
              actions: {
                _AnswerIntent: CallbackAction<_AnswerIntent>(
                  onInvoke: (intent) => controller.setAnswer(question.id, intent.value),
                ),
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _QuestionCard(
                            question: question,
                            isKo: isKo,
                            index: controller.currentIndex + 1,
                          ),
                          const SizedBox(height: 18),
                          _AnswerScale(
                            isKo: isKo,
                            factor: question.factor,
                            currentAnswer: currentAnswer,
                            onSelect: (value) => controller.setAnswer(question.id, value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            onPressed: controller.currentIndex == 0 ? null : controller.prev,
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
                            child: Text(
                              isLast ? (isKo ? '완료' : 'Finish') : (isKo ? '다음' : 'Next'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        isKo
                            ? '키보드 1-5로 응답, ← → 로 이동할 수 있어요.'
                            : 'Use 1-5 to answer, ←/→ to move.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.gray500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        isKo ? '천천히 답해도 괜찮아요.' : 'Take your time.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.gray500),
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

class _AnswerIntent extends Intent {
  final int value;
  const _AnswerIntent(this.value);
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
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerScale extends StatelessWidget {
  final bool isKo;
  final String factor;
  final int? currentAnswer;
  final ValueChanged<int> onSelect;

  const _AnswerScale({
    required this.isKo,
    required this.factor,
    required this.currentAnswer,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        final value = index + 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnswerOption(
            value: value,
            label: isKo ? scaleLabelsKo[value]! : scaleLabelsEn[value]!,
            isSelected: currentAnswer == value,
            onTap: () => onSelect(value),
          ),
        );
      }),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _scaleStyle(value);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: style.gradient)
              : const LinearGradient(colors: [AppColors.darkCard, AppColors.darkCard]),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? style.border : AppColors.darkBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? style.border : AppColors.darkBorder,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        value.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : AppColors.gray400,
                    ),
              ),
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : AppColors.gray500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  _ScaleStyle _scaleStyle(int value) {
    switch (value) {
      case 1:
        return _ScaleStyle(
          gradient: [AppColors.red500.withValues(alpha: 0.25), AppColors.red500.withValues(alpha: 0.15)],
          border: AppColors.red500,
        );
      case 2:
        return _ScaleStyle(
          gradient: [AppColors.orange500.withValues(alpha: 0.25), AppColors.orange500.withValues(alpha: 0.15)],
          border: AppColors.orange500,
        );
      case 3:
        return _ScaleStyle(
          gradient: [AppColors.gray700.withValues(alpha: 0.4), AppColors.gray700.withValues(alpha: 0.2)],
          border: AppColors.gray500,
        );
      case 4:
        return _ScaleStyle(
          gradient: [AppColors.blue500.withValues(alpha: 0.25), AppColors.blue500.withValues(alpha: 0.15)],
          border: AppColors.blue500,
        );
      default:
        return _ScaleStyle(
          gradient: [AppColors.emerald500.withValues(alpha: 0.25), AppColors.emerald500.withValues(alpha: 0.15)],
          border: AppColors.emerald500,
        );
    }
  }
}

class _ScaleStyle {
  final List<Color> gradient;
  final Color border;

  const _ScaleStyle({required this.gradient, required this.border});
}
