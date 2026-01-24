import 'package:flutter/material.dart';

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

        return AppScaffold(
          appBar: AppHeader(controller: controller),
          scroll: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressHeader(
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
                    _QuestionCard(question: question, isKo: isKo),
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
                      onPressed: currentAnswer == null
                          ? null
                          : () {
                              if (isLast && controller.isComplete) {
                                Navigator.pushNamed(context, '/result');
                              } else {
                                controller.next();
                              }
                            },
                      child: Text(
                        isLast ? (isKo ? '완료' : 'Finish') : (isKo ? '다음' : 'Next'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  isKo ? '답변은 언제든 변경할 수 있어요.' : 'You can change any answer anytime.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.gray500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int total;
  final double progress;
  final String factor;
  final bool isKo;

  const _ProgressHeader({
    required this.currentIndex,
    required this.total,
    required this.progress,
    required this.factor,
    required this.isKo,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);
    final factorName = isKo ? factorNamesKo[factor] ?? '' : factorNamesEn[factor] ?? '';
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.darkBorder,
            color: accent,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isKo ? '$factorName · $factor 요인' : '$factorName · $factor factor',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Question question;
  final bool isKo;

  const _QuestionCard({required this.question, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final color = factorColors[question.factor] ?? AppColors.purple500;
    final factorName = isKo ? factorNamesKo[question.factor] ?? '' : factorNamesEn[question.factor] ?? '';

    return DarkCard(
      padding: const EdgeInsets.all(20),
      radius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Text(
                  factorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const Spacer(),
              Text(
                question.factor,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isKo ? question.ko : question.en,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4),
          ),
        ],
      ),
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
            accent: factorColors[factor] ?? AppColors.purple500,
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
  final Color accent;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? accent.withValues(alpha: 0.18) : AppColors.darkCard;
    final border = isSelected ? accent : AppColors.darkBorder;
    final textColor = isSelected ? Colors.white : AppColors.gray400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? accent : AppColors.darkBorder,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 18,
                color: accent,
              ),
          ],
        ),
      ),
    );
  }
}
