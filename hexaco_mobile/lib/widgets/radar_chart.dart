import 'dart:math';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../ui/app_tokens.dart';

class RadarChart extends StatelessWidget {
  final Map<String, double> scores;
  final double size;

  const RadarChart({super.key, required this.scores, this.size = 280});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(scores),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Map<String, double> scores;

  _RadarPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 24;
    const levels = 5;

    final gridPaint = Paint()
      ..color = AppColors.darkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var level = 1; level <= levels; level += 1) {
      final r = radius * (level / levels);
      final path = Path();
      for (var i = 0; i < factorOrder.length; i += 1) {
        final angle = -pi / 2 + (2 * pi / factorOrder.length) * i;
        final point = center + Offset(cos(angle), sin(angle)) * r;
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    final axisPaint = Paint()
      ..color = AppColors.darkBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < factorOrder.length; i += 1) {
      final angle = -pi / 2 + (2 * pi / factorOrder.length) * i;
      final point = center + Offset(cos(angle), sin(angle)) * radius;
      canvas.drawLine(center, point, axisPaint);
    }

    final valuePath = Path();
    for (var i = 0; i < factorOrder.length; i += 1) {
      final factor = factorOrder[i];
      final score = (scores[factor] ?? 0).clamp(0, 100);
      final angle = -pi / 2 + (2 * pi / factorOrder.length) * i;
      final r = radius * (score / 100);
      final point = center + Offset(cos(angle), sin(angle)) * r;
      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }
    valuePath.close();

    final fillPaint = Paint()
      ..color = AppColors.purple500.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.purple500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, strokePaint);

    for (var i = 0; i < factorOrder.length; i += 1) {
      final factor = factorOrder[i];
      final angle = -pi / 2 + (2 * pi / factorOrder.length) * i;
      final labelOffset = center + Offset(cos(angle), sin(angle)) * (radius + 16);

      final textPainter = TextPainter(
        text: TextSpan(
          text: factor,
          style: const TextStyle(
            color: AppColors.gray400,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelPos = labelOffset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, labelPos);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
