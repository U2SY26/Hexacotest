import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/personality_card.dart';
import 'hologram_card.dart';

/// 가챠 스타일 카드 뽑기 다이얼로그
class CardRevealDialog extends StatefulWidget {
  final PersonalityCard card;
  final bool isKo;

  const CardRevealDialog({
    super.key,
    required this.card,
    required this.isKo,
  });

  @override
  State<CardRevealDialog> createState() => _CardRevealDialogState();
}

enum _Phase { pack, burst, reveal, interactive }

class _CardRevealDialogState extends State<CardRevealDialog>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.pack;

  late AnimationController _packGlowController;
  late AnimationController _burstController;
  late AnimationController _revealController;
  late AnimationController _sparkleController;

  // Particles for burst effect
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _packGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _generateParticles();
  }

  void _generateParticles() {
    final rand = Random();
    final count = switch (widget.card.rarity) {
      CardRarity.legend => 50,
      CardRarity.ssr => 35,
      CardRarity.sr => 25,
      CardRarity.r => 15,
    };
    final colors = _getRarityColors();

    _particles = List.generate(count, (i) {
      final angle = (2 * pi * i) / count + (rand.nextDouble() - 0.5) * 0.5;
      final distance = 120 + rand.nextDouble() * 200;
      return _Particle(
        angle: angle,
        distance: distance,
        size: rand.nextDouble() * 5 + 2,
        color: colors[i % colors.length],
        delay: rand.nextDouble() * 0.15,
      );
    });
  }

  List<Color> _getRarityColors() {
    return switch (widget.card.rarity) {
      CardRarity.legend => [
        const Color(0xFFFBBF24), const Color(0xFFF59E0B),
        const Color(0xFFFDE68A), const Color(0xFFEF4444),
        const Color(0xFFA855F7), const Color(0xFF3B82F6),
      ],
      CardRarity.ssr => [
        const Color(0xFFA855F7), const Color(0xFFC084FC),
        const Color(0xFFE879F9), const Color(0xFF7C3AED),
      ],
      CardRarity.sr => [
        const Color(0xFF3B82F6), const Color(0xFF60A5FA),
        const Color(0xFF93C5FD), const Color(0xFF2563EB),
      ],
      CardRarity.r => [
        const Color(0xFF94A3B8), const Color(0xFFCBD5E1),
        const Color(0xFFE2E8F0),
      ],
    };
  }

  void _onPackTap() {
    HapticFeedback.heavyImpact();

    setState(() => _phase = _Phase.burst);
    _burstController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _phase = _Phase.reveal);
      _revealController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _phase = _Phase.interactive);
    });
  }

  @override
  void dispose() {
    _packGlowController.dispose();
    _burstController.dispose();
    _revealController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: _phase == _Phase.interactive ? () => Navigator.of(context).pop() : null,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.92),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vignette
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                      radius: 0.8,
                    ),
                  ),
                ),
              ),

              // Burst particles
              if (_phase == _Phase.burst || _phase == _Phase.reveal)
                _BurstParticles(
                  particles: _particles,
                  controller: _burstController,
                ),

              // Light rays
              if (_phase == _Phase.burst || _phase == _Phase.reveal || _phase == _Phase.interactive)
                _LightRays(
                  rarity: widget.card.rarity,
                  sparkleController: _sparkleController,
                ),

              // Card pack (tap to open)
              if (_phase == _Phase.pack)
                _CardPack(
                  rarity: widget.card.rarity,
                  glowController: _packGlowController,
                  onTap: _onPackTap,
                  isKo: widget.isKo,
                ),

              // Card reveal
              if (_phase == _Phase.reveal || _phase == _Phase.interactive)
                AnimatedBuilder(
                  animation: _revealController,
                  builder: (context, child) {
                    final scale = Curves.elasticOut.transform(
                      _revealController.value.clamp(0.0, 1.0),
                    );
                    return Transform.scale(
                      scale: 0.3 + 0.7 * scale,
                      child: Opacity(
                        opacity: _revealController.value.clamp(0.0, 1.0),
                        child: HologramCard(
                          card: widget.card,
                          isKo: widget.isKo,
                        ),
                      ),
                    );
                  },
                ),

              // Rarity announcement
              if (_phase == _Phase.reveal || _phase == _Phase.interactive)
                Positioned(
                  bottom: 80,
                  child: _RarityBadge(
                    rarity: widget.card.rarity,
                    isKo: widget.isKo,
                    controller: _revealController,
                  ),
                ),

              // Close hint
              if (_phase == _Phase.interactive)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 28,
                    ),
                  ),
                ),

              // Floating sparkles (LEGEND/SSR)
              if (widget.card.rarity == CardRarity.legend ||
                  widget.card.rarity == CardRarity.ssr)
                _FloatingSparkles(
                  controller: _sparkleController,
                  rarity: widget.card.rarity,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 팩 (탭 전 대기 상태)
class _CardPack extends StatelessWidget {
  final CardRarity rarity;
  final AnimationController glowController;
  final VoidCallback onTap;
  final bool isKo;

  const _CardPack({
    required this.rarity,
    required this.glowController,
    required this.onTap,
    required this.isKo,
  });

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[rarity]!;
    final borderColor = Color(config.borderColor);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: glowController,
        builder: (context, child) {
          final glow = 0.3 + glowController.value * 0.4;
          return Container(
            width: 200,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1035),
                  const Color(0xFF2D1B4E),
                  const Color(0xFF1A1035),
                ],
              ),
              border: Border.all(
                color: borderColor.withValues(alpha: glow),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: glow * 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: borderColor.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 16),
                Text(
                  isKo ? '탭하여 열기' : 'Tap to Open',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: glowController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.4 + glowController.value * 0.3,
                      child: Text(
                        '${config.icon} ${rarity == CardRarity.legend ? '✨' : ''}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 폭발 파티클
class _BurstParticles extends StatelessWidget {
  final List<_Particle> particles;
  final AnimationController controller;

  const _BurstParticles({required this.particles, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(
            particles: particles,
            progress: controller.value,
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double delay;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset center;

  _ParticlePainter({required this.particles, required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = center.dx + cos(p.angle) * p.distance * t;
      final y = center.dy + sin(p.angle) * p.distance * t;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final s = p.size * (1.0 - t * 0.5);

      canvas.drawCircle(
        Offset(x, y),
        s,
        Paint()
          ..color = p.color.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 빛줄기 효과
class _LightRays extends StatelessWidget {
  final CardRarity rarity;
  final AnimationController sparkleController;

  const _LightRays({required this.rarity, required this.sparkleController});

  @override
  Widget build(BuildContext context) {
    if (rarity == CardRarity.r) return const SizedBox.shrink();

    final config = rarityConfigs[rarity]!;
    final color = Color(config.borderColor);

    return AnimatedBuilder(
      animation: sparkleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _LightRayPainter(
            color: color,
            rotation: sparkleController.value * 2 * pi,
            rayCount: rarity == CardRarity.legend ? 12 : rarity == CardRarity.ssr ? 8 : 6,
          ),
        );
      },
    );
  }
}

class _LightRayPainter extends CustomPainter {
  final Color color;
  final double rotation;
  final int rayCount;

  _LightRayPainter({required this.color, required this.rotation, required this.rayCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxLen = size.longestSide * 0.7;

    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (2 * pi * i) / rayCount;
      final endX = center.dx + cos(angle) * maxLen;
      final endY = center.dy + sin(angle) * maxLen;

      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(center, Offset(endX, endY)))
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightRayPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

/// 레어도 배지 애니메이션
class _RarityBadge extends StatelessWidget {
  final CardRarity rarity;
  final bool isKo;
  final AnimationController controller;

  const _RarityBadge({required this.rarity, required this.isKo, required this.controller});

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[rarity]!;
    final color = Color(config.borderColor);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.elasticOut.transform(controller.value.clamp(0.0, 1.0));
        return Transform.scale(
          scale: t,
          child: Opacity(
            opacity: controller.value.clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '${config.icon} ${isKo ? config.labelKo : config.label}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 떠다니는 스파클 (레전더리/에픽용)
class _FloatingSparkles extends StatelessWidget {
  final AnimationController controller;
  final CardRarity rarity;

  const _FloatingSparkles({required this.controller, required this.rarity});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _SparklePainter(
            progress: controller.value,
            isLegendary: rarity == CardRarity.legend,
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final bool isLegendary;

  _SparklePainter({required this.progress, required this.isLegendary});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42); // Fixed seed for consistent positions
    final count = isLegendary ? 25 : 15;
    final color = isLegendary
        ? const Color(0xFFFBBF24)
        : const Color(0xFFA855F7);

    for (var i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = (progress + i * 0.05) % 1.0;
      final y = baseY - phase * 60;
      final opacity = sin(phase * pi) * 0.7;
      final s = rand.nextDouble() * 3 + 1;

      if (opacity > 0) {
        canvas.drawCircle(
          Offset(x, y),
          s,
          Paint()
            ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
