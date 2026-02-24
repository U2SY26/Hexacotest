import 'package:flutter/material.dart';

import '../controllers/test_controller.dart';
import '../ui/app_tokens.dart';
import 'glass_container.dart';
import 'gradient_text.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final TestController controller;

  const AppHeader({super.key, required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isKo = controller.language == 'ko';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        radius: AppRadii.lg,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.purple500.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hexagon, color: AppColors.purple500, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientText(
                    isKo ? '5분 나를 알아보는 시간' : '5 Min to Know Yourself',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isKo ? '6가지 심리 유형 테스트' : '6-Type Personality Test',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Settings button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/settings'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 20,
                    color: AppColors.gray300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
