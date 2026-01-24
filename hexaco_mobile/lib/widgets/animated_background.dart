import 'dart:math';

import 'package:flutter/material.dart';

import '../ui/app_tokens.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.maybeOf(context);
    final reduce = (media?.disableAnimations ?? false) ||
        (media?.accessibleNavigation ?? false);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      if (_reduceMotion) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduceMotion) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final begin = Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, t)!;
        final end = Alignment.lerp(Alignment.bottomRight, Alignment.topLeft, t)!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppGradients.background.colors,
                  begin: begin,
                  end: end,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _ParticlePainter(t),
                  ),
                  _Orb(
                    size: size,
                    progress: t,
                    color: AppColors.purple500.withValues(alpha: 0.18),
                    radius: 220,
                    base: const Offset(0.2, 0.25),
                    drift: const Offset(0.1, 0.05),
                  ),
                  _Orb(
                    size: size,
                    progress: t + 0.3,
                    color: AppColors.pink500.withValues(alpha: 0.16),
                    radius: 260,
                    base: const Offset(0.8, 0.2),
                    drift: const Offset(0.08, 0.07),
                  ),
                  _Orb(
                    size: size,
                    progress: t + 0.6,
                    color: AppColors.blue500.withValues(alpha: 0.12),
                    radius: 200,
                    base: const Offset(0.75, 0.7),
                    drift: const Offset(0.06, 0.05),
                  ),
                  widget.child,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final Size size;
  final double progress;
  final Color color;
  final double radius;
  final Offset base;
  final Offset drift;

  const _Orb({
    required this.size,
    required this.progress,
    required this.color,
    required this.radius,
    required this.base,
    required this.drift,
  });

  @override
  Widget build(BuildContext context) {
    final t = progress * 2 * pi;
    final dx = base.dx + sin(t) * drift.dx;
    final dy = base.dy + cos(t) * drift.dy;
    final left = size.width * dx - radius / 2;
    final top = size.height * dy - radius / 2;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (var i = 0; i < 28; i += 1) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final pulse = 0.35 + 0.25 * sin((progress * 2 * pi) + i);
      final radius = 1.2 + (i % 3) * 0.6;
      final paint = Paint()
        ..color = (i % 2 == 0 ? AppColors.purple400 : AppColors.pink500)
            .withValues(alpha: pulse);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
