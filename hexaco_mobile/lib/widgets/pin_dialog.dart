import 'package:flutter/material.dart';

import '../ui/app_tokens.dart';

class PinDialog extends StatefulWidget {
  final bool isKo;
  final String? title;
  final String? subtitle;

  const PinDialog({super.key, required this.isKo, this.title, this.subtitle});

  static Future<String?> show(
    BuildContext context, {
    required bool isKo,
    String? title,
    String? subtitle,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinDialog(isKo: isKo, title: title, subtitle: subtitle),
    );
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  String _pin = '';

  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() => _pin += digit);
      if (_pin.length == 4) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) Navigator.pop(context, _pin);
        });
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? (widget.isKo ? 'PIN 입력' : 'Enter PIN');
    final subtitle = widget.subtitle;

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xl)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.gray400),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.purple500 : Colors.transparent,
                    border: Border.all(
                      color: filled ? AppColors.purple500 : AppColors.darkBorder,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            _buildKeypad(),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                widget.isKo ? '취소' : 'Cancel',
                style: const TextStyle(color: AppColors.gray400, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'DEL'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 56);
            }
            final isDel = key == 'DEL';
            return SizedBox(
              width: 72,
              height: 56,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  onTap: isDel ? _removeDigit : () => _addDigit(key),
                  child: Center(
                    child: isDel
                        ? const Icon(Icons.backspace_outlined, color: AppColors.gray400, size: 22)
                        : Text(
                            key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
