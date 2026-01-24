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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        radius: AppRadii.lg,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.purple500.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hexagon, color: AppColors.purple500),
            ),
            const SizedBox(width: 12),
            const GradientText(
              'HEXACO',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              maxLines: 1,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => controller.setLanguage(isKo ? 'en' : 'ko'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.darkBorder),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.darkCard,
              ),
              icon: const Icon(Icons.language, size: 16, color: AppColors.gray400),
              label: Text(isKo ? 'EN' : '한국어'),
            ),
          ],
        ),
      ),
    );
  }
}
