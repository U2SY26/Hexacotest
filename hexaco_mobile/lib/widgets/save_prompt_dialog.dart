import 'package:flutter/material.dart';

import '../ui/app_tokens.dart';

class SavePromptDialog {
  /// Returns:
  ///   true  - user wants to save
  ///   false - user confirmed leave without saving
  ///   null  - user cancelled (stay on result screen)
  static Future<bool?> show(BuildContext context, {required bool isKo}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SaveDialog(isKo: isKo),
    );

    if (result == null) return null; // cancelled
    if (result) return true; // wants to save

    // User said no → show warning
    if (!context.mounted) return false;
    final confirmLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WarningDialog(isKo: isKo),
    );

    if (confirmLeave == true) return false; // confirmed leave
    return null; // went back
  }
}

class _SaveDialog extends StatelessWidget {
  final bool isKo;
  const _SaveDialog({required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.save_outlined, color: AppColors.purple400, size: 40),
            const SizedBox(height: 16),
            Text(
              isKo ? '결과를 저장하시겠습니까?' : 'Save your result?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isKo ? '4자리 PIN으로 보호하여 나중에 다시 볼 수 있습니다.' : 'Protect with a 4-digit PIN to view later.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: isKo ? '아니오' : 'No',
                    onTap: () => Navigator.pop(context, false),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: isKo ? '저장하기' : 'Save',
                    onTap: () => Navigator.pop(context, true),
                    isPrimary: true,
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

class _WarningDialog extends StatelessWidget {
  final bool isKo;
  const _WarningDialog({required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.orange500, size: 40),
            const SizedBox(height: 16),
            Text(
              isKo ? '정말 나가시겠습니까?' : 'Are you sure?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isKo
                  ? '저장하지 않으면 결과가 영구적으로 사라집니다.'
                  : 'Your result will be permanently lost.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.red500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _DialogButton(
                    label: isKo ? '돌아가기' : 'Go Back',
                    onTap: () => Navigator.pop(context, false),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: isKo ? '나가기' : 'Leave',
                    onTap: () => Navigator.pop(context, true),
                    isPrimary: true,
                    isDestructive: true,
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

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDestructive;

  const _DialogButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isPrimary && !isDestructive ? AppGradients.primaryButton : null,
            color: isDestructive
                ? AppColors.red500.withValues(alpha: 0.2)
                : (!isPrimary ? AppColors.darkBg : null),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: !isPrimary ? Border.all(color: AppColors.darkBorder) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isDestructive ? AppColors.red500 : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
