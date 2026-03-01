import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/personality_card.dart';
import 'hologram_card.dart';

/// 가챠 스타일 카드 뽑기 — 아름다운 풀스크린 연출
class CardRevealDialog extends StatefulWidget {
  final PersonalityCard card;
  final bool isKo;

  const CardRevealDialog({super.key, required this.card, required this.isKo});

  @override
  State<CardRevealDialog> createState() => _CardRevealDialogState();
}

enum _Phase { anticipation, crack, burst, cardIn, interactive }

class _CardRevealDialogState extends State<CardRevealDialog>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.anticipation;

  // Core animation controllers
  late AnimationController _glowPulse;      // 1.8s — pack breathing
  late AnimationController _energyOrbit;    // 4s — orbiting energy
  late AnimationController _crackFlash;     // 0.4s — crack/flash
  late AnimationController _burstExpand;    // 1.0s — shockwave + particles
  late AnimationController _cardEntrance;   // 0.8s — card zoom-in
  late AnimationController _ambientLoop;    // 6s — ambient sparkles/rays
  late AnimationController _auroraLoop;     // 10s — background aurora

  // Particle data
  late List<_BurstParticle> _burstParticles;
  late List<_TrailParticle> _trailParticles;
  late List<_EnergyOrb> _energyOrbs;

  @override
  void initState() {
    super.initState();

    _glowPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _energyOrbit = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();
    _crackFlash = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _burstExpand = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _cardEntrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _ambientLoop = AnimationController(vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();
    _auroraLoop = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000))
      ..repeat();

    _generateParticles();
  }

  void _generateParticles() {
    final rand = Random();
    final rarity = widget.card.rarity;
    final colors = _rarityColors(rarity);

    // Burst particles (explosion on open)
    final burstCount = switch (rarity) {
      CardRarity.legend => 80,
      CardRarity.ssr => 55,
      CardRarity.sr => 35,
      CardRarity.r => 20,
    };
    _burstParticles = List.generate(burstCount, (i) {
      final angle = (2 * pi * i) / burstCount + (rand.nextDouble() - 0.5) * 0.6;
      return _BurstParticle(
        angle: angle,
        distance: 100 + rand.nextDouble() * 350,
        size: rand.nextDouble() * 6 + 1.5,
        color: colors[i % colors.length],
        delay: rand.nextDouble() * 0.12,
        type: i % 5 == 0 ? _ParticleType.star : (i % 3 == 0 ? _ParticleType.streak : _ParticleType.dot),
        speed: 0.7 + rand.nextDouble() * 0.6,
      );
    });

    // Trail particles (rising from bottom, continuous)
    _trailParticles = List.generate(40, (i) {
      return _TrailParticle(
        x: rand.nextDouble(),
        speed: 0.3 + rand.nextDouble() * 0.7,
        size: rand.nextDouble() * 3 + 0.8,
        color: colors[i % colors.length],
        delay: rand.nextDouble(),
        sway: (rand.nextDouble() - 0.5) * 30,
      );
    });

    // Energy orbs (orbiting the pack)
    final orbCount = switch (rarity) {
      CardRarity.legend => 6,
      CardRarity.ssr => 4,
      CardRarity.sr => 3,
      CardRarity.r => 2,
    };
    _energyOrbs = List.generate(orbCount, (i) {
      return _EnergyOrb(
        orbitRadius: 90 + rand.nextDouble() * 50,
        phase: (2 * pi * i) / orbCount,
        size: 4 + rand.nextDouble() * 4,
        color: colors[i % colors.length],
        speed: 0.8 + rand.nextDouble() * 0.4,
      );
    });
  }

  List<Color> _rarityColors(CardRarity rarity) {
    return switch (rarity) {
      CardRarity.legend => const [
        Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFFDE68A),
        Color(0xFFEF4444), Color(0xFFA855F7), Color(0xFF3B82F6),
        Color(0xFFFFFFFF),
      ],
      CardRarity.ssr => const [
        Color(0xFFA855F7), Color(0xFFC084FC), Color(0xFFE879F9),
        Color(0xFF7C3AED), Color(0xFFEC4899),
      ],
      CardRarity.sr => const [
        Color(0xFF3B82F6), Color(0xFF60A5FA), Color(0xFF93C5FD),
        Color(0xFF2563EB), Color(0xFF06B6D4),
      ],
      CardRarity.r => const [
        Color(0xFF94A3B8), Color(0xFFCBD5E1), Color(0xFFE2E8F0),
      ],
    };
  }

  Color _rarityGlow(CardRarity rarity) {
    return switch (rarity) {
      CardRarity.legend => const Color(0xFFFBBF24),
      CardRarity.ssr => const Color(0xFFA855F7),
      CardRarity.sr => const Color(0xFF3B82F6),
      CardRarity.r => const Color(0xFF94A3B8),
    };
  }

  void _onPackTap() {
    HapticFeedback.heavyImpact();

    // Phase 1: Crack + flash (0-400ms)
    setState(() => _phase = _Phase.crack);
    _crackFlash.forward();

    // Phase 2: Burst (400-1400ms)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() => _phase = _Phase.burst);
      _burstExpand.forward();
    });

    // Phase 3: Card entrance (900-1700ms)
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _phase = _Phase.cardIn);
      _cardEntrance.forward();
    });

    // Phase 4: Interactive (1700ms+)
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() => _phase = _Phase.interactive);
    });
  }

  @override
  void dispose() {
    _glowPulse.dispose();
    _energyOrbit.dispose();
    _crackFlash.dispose();
    _burstExpand.dispose();
    _cardEntrance.dispose();
    _ambientLoop.dispose();
    _auroraLoop.dispose();
    super.dispose();
  }

  bool get _showCard =>
      _phase == _Phase.cardIn || _phase == _Phase.interactive;

  bool get _showBurst =>
      _phase == _Phase.burst || _phase == _Phase.cardIn || _phase == _Phase.interactive;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rarity = widget.card.rarity;
    final isHighRarity = rarity == CardRarity.ssr || rarity == CardRarity.legend;
    final isLegend = rarity == CardRarity.legend;
    final glowColor = _rarityGlow(rarity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: _phase == _Phase.interactive ? () => Navigator.of(context).pop() : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _glowPulse, _energyOrbit, _crackFlash,
            _burstExpand, _cardEntrance, _ambientLoop, _auroraLoop,
          ]),
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ─── Layer 0: Background aurora ────────────────────
                  if (isHighRarity)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AuroraBackgroundPainter(
                          progress: _auroraLoop.value,
                          color: glowColor,
                          intensity: _showBurst ? 0.15 : 0.05,
                          isLegend: isLegend,
                        ),
                      ),
                    ),

                  // ─── Layer 1: Rising trail particles ───────────────
                  if (_showBurst)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TrailParticlesPainter(
                          particles: _trailParticles,
                          progress: _ambientLoop.value,
                          screenSize: size,
                        ),
                      ),
                    ),

                  // ─── Layer 2: Vignette ─────────────────────────────
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          radius: 0.75,
                        ),
                      ),
                    ),
                  ),

                  // ─── Layer 3: Shockwave ring ───────────────────────
                  if (_showBurst)
                    _ShockwaveRing(
                      progress: _burstExpand.value,
                      color: glowColor,
                      isLegend: isLegend,
                    ),

                  // ─── Layer 4: Light rays ───────────────────────────
                  if (_showBurst && rarity != CardRarity.r)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LightRaysPainter(
                          rotation: _ambientLoop.value * 2 * pi,
                          color: glowColor,
                          rayCount: isLegend ? 16 : isHighRarity ? 10 : 6,
                          intensity: isLegend ? 0.2 : 0.12,
                          fadeIn: _burstExpand.value.clamp(0.0, 1.0),
                        ),
                      ),
                    ),

                  // ─── Layer 5: Burst particles ──────────────────────
                  if (_showBurst)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BurstParticlesPainter(
                          particles: _burstParticles,
                          progress: _burstExpand.value,
                          center: Offset(size.width / 2, size.height / 2),
                        ),
                      ),
                    ),

                  // ─── Layer 6: Energy orbs (anticipation only) ──────
                  if (_phase == _Phase.anticipation)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _EnergyOrbsPainter(
                          orbs: _energyOrbs,
                          progress: _energyOrbit.value,
                          center: Offset(size.width / 2, size.height / 2),
                        ),
                      ),
                    ),

                  // ─── Layer 7: Screen flash ─────────────────────────
                  if (_phase == _Phase.crack || _phase == _Phase.burst)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          color: _phase == _Phase.crack
                              ? glowColor.withValues(
                                  alpha: (1.0 - _crackFlash.value) * (isLegend ? 0.7 : 0.4))
                              : glowColor.withValues(
                                  alpha: (1.0 - _burstExpand.value) * 0.3),
                        ),
                      ),
                    ),

                  // ─── Layer 8: Card pack ────────────────────────────
                  if (_phase == _Phase.anticipation)
                    _PremiumCardPack(
                      rarity: rarity,
                      glowPulse: _glowPulse.value,
                      energyOrbit: _energyOrbit.value,
                      onTap: _onPackTap,
                      isKo: widget.isKo,
                    ),

                  // ─── Layer 9: Card reveal ──────────────────────────
                  if (_showCard) ...[
                    Builder(builder: (context) {
                      final t = Curves.elasticOut.transform(
                        _cardEntrance.value.clamp(0.0, 1.0),
                      );
                      final scale = 0.15 + 0.85 * t;
                      final opacity = _cardEntrance.value.clamp(0.0, 1.0);
                      // Slight spin on entrance
                      final spin = (1.0 - _cardEntrance.value.clamp(0.0, 1.0)) * 0.1;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(spin * pi)
                          ..scale(scale),
                        child: Opacity(
                          opacity: opacity,
                          child: HologramCard(
                            card: widget.card,
                            isKo: widget.isKo,
                          ),
                        ),
                      );
                    }),
                  ],

                  // ─── Layer 10: Floating ambient sparkles ───────────
                  if (_phase == _Phase.interactive && isHighRarity)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _FloatingSparklesPainter(
                          progress: _ambientLoop.value,
                          isLegend: isLegend,
                          color: glowColor,
                        ),
                      ),
                    ),

                  // ─── Layer 11: Rarity announcement ─────────────────
                  if (_showCard)
                    Positioned(
                      bottom: 70,
                      child: _PremiumRarityBadge(
                        rarity: rarity,
                        isKo: widget.isKo,
                        entranceValue: _cardEntrance.value,
                        pulseValue: _ambientLoop.value,
                      ),
                    ),

                  // ─── Layer 12: Close button ────────────────────────
                  if (_phase == _Phase.interactive)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close,
                          color: Colors.white.withValues(alpha: 0.4), size: 28),
                      ),
                    ),

                  // ─── Layer 13: Tap hint ────────────────────────────
                  if (_phase == _Phase.interactive)
                    Positioned(
                      bottom: 30,
                      child: Opacity(
                        opacity: 0.3 + sin(_ambientLoop.value * 2 * pi) * 0.15,
                        child: Text(
                          widget.isKo ? '탭하여 닫기' : 'Tap to close',
                          style: const TextStyle(
                            color: Colors.white54, fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Card Pack (anticipation phase)
// ═══════════════════════════════════════════════════════════════════════════════

class _PremiumCardPack extends StatelessWidget {
  final CardRarity rarity;
  final double glowPulse;
  final double energyOrbit;
  final VoidCallback onTap;
  final bool isKo;

  const _PremiumCardPack({
    required this.rarity, required this.glowPulse,
    required this.energyOrbit, required this.onTap, required this.isKo,
  });

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[rarity]!;
    final borderColor = Color(config.borderColor);
    final isHighRarity = rarity == CardRarity.ssr || rarity == CardRarity.legend;
    final isLegend = rarity == CardRarity.legend;
    final glow = 0.3 + glowPulse * 0.5;
    final breatheScale = 1.0 + sin(glowPulse * pi) * 0.02;

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: breatheScale,
        child: Container(
          width: 210,
          height: 290,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0820),
                Color(config.glowColor).withValues(alpha: 0.15),
                const Color(0xFF0D0820),
              ],
            ),
            border: Border.all(
              color: borderColor.withValues(alpha: glow),
              width: isLegend ? 2.5 : 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: glow * 0.5),
                blurRadius: isLegend ? 50 : 30,
                spreadRadius: isLegend ? 10 : 5,
              ),
              if (isHighRarity)
                BoxShadow(
                  color: borderColor.withValues(alpha: glow * 0.2),
                  blurRadius: 80,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background pattern
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CustomPaint(
                    painter: _PackPatternPainter(
                      color: borderColor,
                      progress: energyOrbit,
                    ),
                  ),
                ),
              ),

              // Center icon area
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glow ring around icon
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withValues(alpha: glow * 0.4),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating ring
                        CustomPaint(
                          size: const Size(80, 80),
                          painter: _SpinningRingPainter(
                            progress: energyOrbit,
                            color: borderColor,
                          ),
                        ),
                        // Center icon
                        Text(config.icon, style: const TextStyle(fontSize: 36)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tap prompt with shimmer
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white,
                        Colors.white.withValues(alpha: 0.6),
                      ],
                      stops: [
                        (glowPulse - 0.3).clamp(0.0, 1.0),
                        glowPulse,
                        (glowPulse + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      isKo ? '탭하여 열기' : 'Tap to Open',
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white, letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Pulsing arrow
                  Opacity(
                    opacity: 0.3 + glowPulse * 0.4,
                    child: Icon(Icons.touch_app, size: 20,
                      color: borderColor.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pack background pattern
class _PackPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  _PackPatternPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Rotating concentric shapes
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(progress * 2 * pi * 0.1);

    for (var i = 1; i <= 6; i++) {
      final r = i * 22.0;
      final path = Path();
      for (var j = 0; j < 6; j++) {
        final angle = pi / 3 * j - pi / 2;
        final x = r * cos(angle);
        final y = r * sin(angle);
        if (j == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PackPatternPainter old) => old.progress != progress;
}

// Spinning ring around icon
class _SpinningRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SpinningRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;

    // Dashed arc
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final startAngle = progress * 2 * pi + (2 * pi * i) / 8;
      final path = Path()..addArc(
        Rect.fromCircle(center: center, radius: r),
        startAngle, pi / 12,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpinningRingPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shockwave Ring
// ═══════════════════════════════════════════════════════════════════════════════

class _ShockwaveRing extends StatelessWidget {
  final double progress;
  final Color color;
  final bool isLegend;

  const _ShockwaveRing({
    required this.progress, required this.color, required this.isLegend,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 1) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final maxRadius = size.longestSide * 0.8;
    final radius = maxRadius * Curves.easeOut.transform(progress);
    final opacity = (1.0 - progress) * (isLegend ? 0.6 : 0.35);
    final width = 3.0 + (1.0 - progress) * (isLegend ? 8 : 4);

    return Positioned.fill(
      child: CustomPaint(
        painter: _ShockwavePainter(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
          color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
          strokeWidth: width,
          isLegend: isLegend,
        ),
      ),
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final double strokeWidth;
  final bool isLegend;

  _ShockwavePainter({
    required this.center, required this.radius, required this.color,
    required this.strokeWidth, required this.isLegend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Main ring
    canvas.drawCircle(center, radius, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth));

    // Inner glow fill
    if (isLegend) {
      canvas.drawCircle(center, radius * 0.95, Paint()
        ..shader = ui.Gradient.radial(center, radius, [
          Colors.transparent,
          color.withValues(alpha: 0.05),
          Colors.transparent,
        ], [0.0, 0.85, 1.0]));
    }
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter old) =>
      old.radius != radius;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Burst Particles
// ═══════════════════════════════════════════════════════════════════════════════

enum _ParticleType { dot, streak, star }

class _BurstParticle {
  final double angle, distance, size, delay, speed;
  final Color color;
  final _ParticleType type;

  _BurstParticle({
    required this.angle, required this.distance, required this.size,
    required this.color, required this.delay, required this.type,
    required this.speed,
  });
}

class _BurstParticlesPainter extends CustomPainter {
  final List<_BurstParticle> particles;
  final double progress;
  final Offset center;

  _BurstParticlesPainter({
    required this.particles, required this.progress, required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final eased = Curves.easeOutCubic.transform(t);
      final dist = p.distance * eased * p.speed;
      final x = center.dx + cos(p.angle) * dist;
      final y = center.dy + sin(p.angle) * dist + (t * t * 40); // gravity
      final opacity = (1.0 - t * t).clamp(0.0, 1.0);
      final s = p.size * (1.0 - t * 0.4);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity);

      switch (p.type) {
        case _ParticleType.dot:
          paint.maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.6);
          canvas.drawCircle(Offset(x, y), s, paint);
          break;
        case _ParticleType.streak:
          // Motion streak
          final prevX = center.dx + cos(p.angle) * dist * 0.85;
          final prevY = center.dy + sin(p.angle) * dist * 0.85 + (t * t * 35);
          paint.strokeWidth = s * 0.4;
          paint.strokeCap = StrokeCap.round;
          paint.maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.3);
          canvas.drawLine(Offset(prevX, prevY), Offset(x, y), paint);
          break;
        case _ParticleType.star:
          // 4-pointed star
          _drawStar(canvas, Offset(x, y), s * 1.5, paint);
          break;
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.4);
    for (var i = 0; i < 4; i++) {
      final angle = pi / 4 * i;
      canvas.drawLine(
        Offset(c.dx + cos(angle) * size, c.dy + sin(angle) * size),
        Offset(c.dx - cos(angle) * size, c.dy - sin(angle) * size),
        paint,
      );
    }
    // Center dot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(c, size * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant _BurstParticlesPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Energy Orbs (orbit around pack)
// ═══════════════════════════════════════════════════════════════════════════════

class _EnergyOrb {
  final double orbitRadius, phase, size, speed;
  final Color color;

  _EnergyOrb({
    required this.orbitRadius, required this.phase,
    required this.size, required this.color, required this.speed,
  });
}

class _EnergyOrbsPainter extends CustomPainter {
  final List<_EnergyOrb> orbs;
  final double progress;
  final Offset center;

  _EnergyOrbsPainter({
    required this.orbs, required this.progress, required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final orb in orbs) {
      final angle = orb.phase + progress * 2 * pi * orb.speed;
      final x = center.dx + cos(angle) * orb.orbitRadius;
      final y = center.dy + sin(angle) * orb.orbitRadius * 0.6; // elliptical

      // Outer glow
      canvas.drawCircle(Offset(x, y), orb.size * 3, Paint()
        ..color = orb.color.withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.size * 2));

      // Core
      canvas.drawCircle(Offset(x, y), orb.size, Paint()
        ..color = orb.color.withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.size * 0.5));

      // Bright center
      canvas.drawCircle(Offset(x, y), orb.size * 0.3, Paint()
        ..color = Colors.white.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyOrbsPainter old) => old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Trail Particles (rising from bottom)
// ═══════════════════════════════════════════════════════════════════════════════

class _TrailParticle {
  final double x, speed, size, delay, sway;
  final Color color;

  _TrailParticle({
    required this.x, required this.speed, required this.size,
    required this.color, required this.delay, required this.sway,
  });
}

class _TrailParticlesPainter extends CustomPainter {
  final List<_TrailParticle> particles;
  final double progress;
  final Size screenSize;

  _TrailParticlesPainter({
    required this.particles, required this.progress, required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final phase = (progress * p.speed + p.delay) % 1.0;
      final y = screenSize.height * (1.0 - phase);
      final x = p.x * screenSize.width + sin(phase * 4 * pi) * p.sway;
      final opacity = sin(phase * pi) * 0.5;

      if (opacity > 0.02) {
        canvas.drawCircle(
          Offset(x, y), p.size,
          Paint()
            ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrailParticlesPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Light Rays
// ═══════════════════════════════════════════════════════════════════════════════

class _LightRaysPainter extends CustomPainter {
  final double rotation;
  final Color color;
  final int rayCount;
  final double intensity;
  final double fadeIn;

  _LightRaysPainter({
    required this.rotation, required this.color,
    required this.rayCount, required this.intensity, required this.fadeIn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxLen = size.longestSide * 0.8;

    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + (2 * pi * i) / rayCount;
      final end = Offset(
        center.dx + cos(angle) * maxLen,
        center.dy + sin(angle) * maxLen,
      );

      // Tapered ray
      final path = Path();
      final perpAngle = angle + pi / 2;
      final halfWidth = 2.0;
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        end.dx + cos(perpAngle) * halfWidth,
        end.dy + sin(perpAngle) * halfWidth,
      );
      path.lineTo(
        end.dx - cos(perpAngle) * halfWidth,
        end.dy - sin(perpAngle) * halfWidth,
      );
      path.close();

      canvas.drawPath(path, Paint()
        ..shader = ui.Gradient.linear(
          center, end,
          [
            color.withValues(alpha: intensity * fadeIn),
            color.withValues(alpha: 0.0),
          ],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter old) =>
      old.rotation != rotation || old.fadeIn != fadeIn;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Aurora Background
// ═══════════════════════════════════════════════════════════════════════════════

class _AuroraBackgroundPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double intensity;
  final bool isLegend;

  _AuroraBackgroundPainter({
    required this.progress, required this.color,
    required this.intensity, required this.isLegend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(7);

    // Flowing aurora waves
    for (var i = 0; i < 4; i++) {
      final baseY = size.height * (0.2 + i * 0.2);
      final phase = (progress + i * 0.25) % 1.0;
      final waveHeight = 60 + rand.nextDouble() * 40;
      final path = Path();

      path.moveTo(0, baseY);
      for (var x = 0.0; x <= size.width; x += 10) {
        final y = baseY + sin((x / size.width * 2 * pi) + phase * 2 * pi + i) * waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      final auroraColor = isLegend
          ? (i % 2 == 0 ? color : const Color(0xFFEF4444))
          : color;

      canvas.drawPath(path, Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, baseY - waveHeight),
          Offset(0, baseY + waveHeight * 2),
          [
            auroraColor.withValues(alpha: intensity * 0.4),
            auroraColor.withValues(alpha: intensity * 0.1),
            Colors.transparent,
          ],
          [0.0, 0.4, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraBackgroundPainter old) =>
      old.progress != progress || old.intensity != intensity;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Floating Sparkles (interactive phase)
// ═══════════════════════════════════════════════════════════════════════════════

class _FloatingSparklesPainter extends CustomPainter {
  final double progress;
  final bool isLegend;
  final Color color;

  _FloatingSparklesPainter({
    required this.progress, required this.isLegend, required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final count = isLegend ? 30 : 18;

    for (var i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = (progress + i * (1.0 / count)) % 1.0;
      final y = baseY - phase * 80;
      final opacity = sin(phase * pi) * 0.6;
      final s = rand.nextDouble() * 2.5 + 1;

      if (opacity <= 0.05) continue;

      final sparkleColor = isLegend
          ? (i % 3 == 0 ? const Color(0xFFFDE68A) : color)
          : color;

      if (i % 5 == 0) {
        // Cross star
        final paint = Paint()
          ..color = sparkleColor.withValues(alpha: opacity.clamp(0.0, 1.0))
          ..strokeWidth = 0.6
          ..style = PaintingStyle.stroke
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s);
        for (var j = 0; j < 4; j++) {
          final angle = pi / 4 * j;
          canvas.drawLine(
            Offset(x + cos(angle) * s * 2, y + sin(angle) * s * 2),
            Offset(x - cos(angle) * s * 2, y - sin(angle) * s * 2),
            paint,
          );
        }
      } else {
        canvas.drawCircle(Offset(x, y), s, Paint()
          ..color = sparkleColor.withValues(alpha: opacity.clamp(0.0, 1.0))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingSparklesPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════════
// Rarity Badge (bottom announcement)
// ═══════════════════════════════════════════════════════════════════════════════

class _PremiumRarityBadge extends StatelessWidget {
  final CardRarity rarity;
  final bool isKo;
  final double entranceValue;
  final double pulseValue;

  const _PremiumRarityBadge({
    required this.rarity, required this.isKo,
    required this.entranceValue, required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[rarity]!;
    final color = Color(config.borderColor);
    final isLegend = rarity == CardRarity.legend;
    final isHighRarity = rarity == CardRarity.ssr || isLegend;

    final t = Curves.elasticOut.transform(entranceValue.clamp(0.0, 1.0));
    final glowPulse = 0.5 + sin(pulseValue * 2 * pi) * 0.3;

    return Transform.scale(
      scale: t,
      child: Opacity(
        opacity: entranceValue.clamp(0.0, 1.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: color.withValues(alpha: 0.5 + glowPulse * 0.3),
              width: isLegend ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3 + glowPulse * 0.2),
                blurRadius: isHighRarity ? 25 : 15,
                spreadRadius: isHighRarity ? 3 : 1,
              ),
            ],
          ),
          child: isLegend
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [
                      Color(0xFFFDE68A), Color(0xFFFFFFFF),
                      Color(0xFFFBBF24), Color(0xFFFFFFFF),
                    ],
                    stops: [
                      (pulseValue - 0.2).clamp(0.0, 1.0),
                      pulseValue.clamp(0.0, 1.0),
                      (pulseValue + 0.15).clamp(0.0, 1.0),
                      (pulseValue + 0.3).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    '${config.icon} ${isKo ? config.labelKo : config.label} ${config.icon}',
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900,
                      color: Colors.white, letterSpacing: 4,
                    ),
                  ),
                )
              : Text(
                  '${config.icon} ${isKo ? config.labelKo : config.label}',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: color, letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
