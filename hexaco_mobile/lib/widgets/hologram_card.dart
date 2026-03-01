import 'dart:math';
import 'package:flutter/material.dart';

import '../models/personality_card.dart';
import '../ui/app_tokens.dart';

/// 요인 색상
const _factorColors = <String, Color>{
  'H': AppColors.purple500,
  'E': AppColors.pink500,
  'X': AppColors.amber500,
  'A': AppColors.emerald500,
  'C': AppColors.blue500,
  'O': Color(0xFFEF4444),
};

const _factorLabelsKo = <String, String>{
  'H': '정직-겸손',
  'E': '정서성',
  'X': '외향성',
  'A': '원만성',
  'C': '성실성',
  'O': '개방성',
};

const _factorLabelsEn = <String, String>{
  'H': 'Honesty',
  'E': 'Emotion',
  'X': 'Extraversion',
  'A': 'Agreeableness',
  'C': 'Conscientiousness',
  'O': 'Openness',
};

/// SSR-스타일 3D 홀로그램 카드
class HologramCard extends StatefulWidget {
  final PersonalityCard card;
  final bool isKo;
  final double width;
  final double height;

  const HologramCard({
    super.key,
    required this.card,
    required this.isKo,
    this.width = 300,
    this.height = 420,
  });

  @override
  State<HologramCard> createState() => _HologramCardState();
}

class _HologramCardState extends State<HologramCard> with TickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotateY += details.delta.dx * 0.4;
      _rotateX -= details.delta.dy * 0.4;
      _rotateX = _rotateX.clamp(-30.0, 30.0);
      _rotateY = _rotateY.clamp(-30.0, 30.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  void _onTap() {
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[widget.card.rarity]!;
    final isHighRarity = widget.card.rarity == CardRarity.ssr || widget.card.rarity == CardRarity.legend;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipController, _shimmerController, _pulseController, _particleController]),
        builder: (context, child) {
          final flipAngle = _flipController.value * pi;
          final isFront = _flipController.value < 0.5;
          final pulseGlow = 0.5 + _pulseController.value * 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..rotateX(_rotateX * pi / 180)
              ..rotateY((_rotateY * pi / 180) + flipAngle),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(config.glowColor).withValues(alpha: pulseGlow * config.glowIntensity),
                    blurRadius: isHighRarity ? 40 : 20,
                    spreadRadius: isHighRarity ? 8 : 3,
                  ),
                  if (isHighRarity)
                    BoxShadow(
                      color: Color(widget.card.theme.secondaryAccent).withValues(alpha: pulseGlow * 0.2),
                      blurRadius: 60,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    if (isFront)
                      _SSRCardFront(
                        card: widget.card,
                        isKo: widget.isKo,
                        shimmerValue: _shimmerController.value,
                        pulseValue: _pulseController.value,
                      )
                    else
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _CardBack(card: widget.card, isKo: widget.isKo),
                      ),

                    // Hologram film overlay
                    _HologramFilmOverlay(
                      shimmerValue: _shimmerController.value,
                      rotateX: _rotateX,
                      rotateY: _rotateY,
                      rarity: widget.card.rarity,
                    ),

                    // Sparkle particles (SR+)
                    if (widget.card.rarity != CardRarity.r)
                      _SparkleParticles(
                        controller: _particleController,
                        rarity: widget.card.rarity,
                        accentColor: Color(widget.card.theme.accentColor),
                      ),

                    // Rainbow edge (SSR/LEGEND)
                    if (isHighRarity)
                      _RainbowEdge(
                        shimmerValue: _shimmerController.value,
                        rarity: widget.card.rarity,
                      ),

                    // Border
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(config.borderColor).withValues(
                              alpha: 0.5 + _pulseController.value * 0.3,
                            ),
                            width: widget.card.rarity == CardRarity.legend ? 2.5 : 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// SSR 스타일 카드 앞면
class _SSRCardFront extends StatelessWidget {
  final PersonalityCard card;
  final bool isKo;
  final double shimmerValue;
  final double pulseValue;

  const _SSRCardFront({
    required this.card,
    required this.isKo,
    required this.shimmerValue,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[card.rarity]!;
    final accent = Color(card.theme.accentColor);
    final secondary = Color(card.theme.secondaryAccent);
    final isHighRarity = card.rarity == CardRarity.ssr || card.rarity == CardRarity.legend;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.theme.gradientColors.map((c) => Color(c)).toList(),
        ),
      ),
      child: Stack(
        children: [
          // Top-right accent glow
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  accent.withValues(alpha: 0.15 + pulseValue * 0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Bottom-left accent glow
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  secondary.withValues(alpha: 0.1 + pulseValue * 0.08),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Geometric pattern for SSR+
          if (isHighRarity)
            Positioned.fill(
              child: CustomPaint(
                painter: _GeometricPatternPainter(color: accent, progress: shimmerValue),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rarity badge + card number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: _getRarityBadgeGradient(card.rarity, accent),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Color(config.borderColor).withValues(alpha: 0.6),
                        ),
                        boxShadow: isHighRarity
                            ? [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 8)]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(config.icon, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            config.label,
                            style: TextStyle(
                              fontSize: card.rarity == CardRarity.legend ? 12 : 11,
                              fontWeight: FontWeight.w900,
                              color: card.rarity == CardRarity.legend
                                  ? const Color(0xFFFDE68A)
                                  : Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      card.cardNumber,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),

                // Central emoji
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [accent.withValues(alpha: 0.2), Colors.transparent],
                        radius: 1.5,
                      ),
                    ),
                    child: Text(card.emoji, style: const TextStyle(fontSize: 56)),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Center(
                  child: Text(
                    isKo ? card.titleKo : card.titleEn,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.3,
                      shadows: isHighRarity
                          ? [Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 10)]
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Quote
                Center(
                  child: Text(
                    '${card.quoteEmoji} ${isKo ? card.quoteKo : card.quoteEn}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55), height: 1.4),
                  ),
                ),
                const Spacer(flex: 3),

                // Top match
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [accent, secondary]),
                        ),
                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          card.topMatchName,
                          style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent.withValues(alpha: 0.3), secondary.withValues(alpha: 0.2)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${card.topMatchSimilarity}%',
                          style: TextStyle(fontSize: 14, color: secondary, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom: MBTI + branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        card.mbti,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      '6가지 심리 유형',
                      style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getRarityBadgeGradient(CardRarity rarity, Color accent) {
    return switch (rarity) {
      CardRarity.legend => const LinearGradient(
        colors: [Color(0x66FBBF24), Color(0x66F59E0B), Color(0x44EF4444)],
      ),
      CardRarity.ssr => LinearGradient(
        colors: [accent.withValues(alpha: 0.4), accent.withValues(alpha: 0.25)],
      ),
      CardRarity.sr => LinearGradient(
        colors: [accent.withValues(alpha: 0.25), accent.withValues(alpha: 0.15)],
      ),
      CardRarity.r => LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.04)],
      ),
    };
  }
}

/// 홀로그램 필름 오버레이
class _HologramFilmOverlay extends StatelessWidget {
  final double shimmerValue;
  final double rotateX;
  final double rotateY;
  final CardRarity rarity;

  const _HologramFilmOverlay({
    required this.shimmerValue,
    required this.rotateX,
    required this.rotateY,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = switch (rarity) {
      CardRarity.legend => 0.18,
      CardRarity.ssr => 0.12,
      CardRarity.sr => 0.07,
      CardRarity.r => 0.03,
    };

    final offsetX = 0.5 + rotateY / 60;
    final offsetY = 0.5 - rotateX / 60;

    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(offsetX * 2 - 1, offsetY * 2 - 1),
            end: Alignment(-offsetX * 2 + 1, -offsetY * 2 + 1),
            colors: [
              Colors.transparent,
              const Color(0xFFFF0000).withValues(alpha: intensity * 0.4),
              const Color(0xFFFF8800).withValues(alpha: intensity * 0.6),
              const Color(0xFFFFFF00).withValues(alpha: intensity * 0.7),
              const Color(0xFF00FF00).withValues(alpha: intensity * 0.6),
              const Color(0xFF0088FF).withValues(alpha: intensity * 0.5),
              const Color(0xFF8800FF).withValues(alpha: intensity * 0.4),
              Colors.transparent,
            ],
            stops: [
              0.0,
              (shimmerValue * 0.8).clamp(0.0, 0.15),
              (shimmerValue * 0.8 + 0.08).clamp(0.0, 0.3),
              (shimmerValue * 0.8 + 0.15).clamp(0.0, 0.5),
              (shimmerValue * 0.8 + 0.22).clamp(0.0, 0.7),
              (shimmerValue * 0.8 + 0.30).clamp(0.0, 0.85),
              (shimmerValue * 0.8 + 0.38).clamp(0.0, 0.95),
              1.0,
            ],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 무지개 테두리 (SSR/LEGEND)
class _RainbowEdge extends StatelessWidget {
  final double shimmerValue;
  final CardRarity rarity;

  const _RainbowEdge({required this.shimmerValue, required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RainbowBorderPainter(
          progress: shimmerValue,
          isLegend: rarity == CardRarity.legend,
        ),
      ),
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final bool isLegend;

  _RainbowBorderPainter({required this.progress, required this.isLegend});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16));
    final colors = isLegend
        ? [
            const Color(0x55FBBF24), const Color(0x55EF4444),
            const Color(0x55A855F7), const Color(0x553B82F6),
            const Color(0x5510B981), const Color(0x55FBBF24),
          ]
        : [
            const Color(0x33A855F7), const Color(0x33EC4899),
            const Color(0x333B82F6), const Color(0x3310B981),
            const Color(0x33A855F7),
          ];

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: progress * 2 * pi,
        endAngle: progress * 2 * pi + 2 * pi,
        colors: colors,
        tileMode: TileMode.repeated,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLegend ? 2.0 : 1.5;

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _RainbowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 반짝이 파티클 (SR+)
class _SparkleParticles extends StatelessWidget {
  final AnimationController controller;
  final CardRarity rarity;
  final Color accentColor;

  const _SparkleParticles({required this.controller, required this.rarity, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SparklesPainter(
              progress: controller.value,
              count: rarityConfigs[rarity]!.particleCount,
              color: accentColor,
              isLegend: rarity == CardRarity.legend,
            ),
          );
        },
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  final double progress;
  final int count;
  final Color color;
  final bool isLegend;

  _SparklesPainter({required this.progress, required this.count, required this.color, required this.isLegend});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    for (var i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = (progress + i * (1.0 / count)) % 1.0;
      final y = baseY - sin(phase * pi) * 20;
      final opacity = sin(phase * pi) * 0.8;
      final s = rand.nextDouble() * 2.5 + 0.5;

      if (opacity > 0.05) {
        final sparkleColor = isLegend && i % 3 == 0 ? const Color(0xFFFDE68A) : color;
        if (isLegend && i % 4 == 0) {
          _drawStar(canvas, Offset(x, y), s * 2, sparkleColor.withValues(alpha: opacity.clamp(0.0, 1.0)));
        } else {
          canvas.drawCircle(
            Offset(x, y), s,
            Paint()
              ..color = sparkleColor.withValues(alpha: opacity.clamp(0.0, 1.0))
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.8),
          );
        }
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = pi / 4 * i;
      path.moveTo(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      path.lineTo(center.dx - cos(angle) * size, center.dy - sin(angle) * size);
    }
    canvas.drawPath(path, Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5));
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) => oldDelegate.progress != progress;
}

/// 기하학 패턴 (SSR/LEGEND)
class _GeometricPatternPainter extends CustomPainter {
  final Color color;
  final double progress;

  _GeometricPatternPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(progress * pi * 0.1);
    for (var ring = 1; ring <= 4; ring++) {
      final r = ring * 40.0;
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = pi / 3 * i - pi / 2;
        final x = r * cos(angle);
        final y = r * sin(angle);
        if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GeometricPatternPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 카드 뒷면 (6가지 유형 점수 + 설명)
class _CardBack extends StatelessWidget {
  final PersonalityCard card;
  final bool isKo;

  const _CardBack({required this.card, required this.isKo});

  @override
  Widget build(BuildContext context) {
    final accent = Color(card.theme.accentColor);
    final config = rarityConfigs[card.rarity]!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.theme.gradientColors.map((c) => Color(c)).toList(),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${config.icon} ${config.label}',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: Color(config.borderColor).withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                card.cardNumber,
                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.25), fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Text(
                  isKo ? '성격 분석' : 'Personality Stats',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent.withValues(alpha: 0.8), letterSpacing: 2),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 40, height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.transparent, accent.withValues(alpha: 0.5), Colors.transparent]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Mini radar
          Center(
            child: SizedBox(
              width: 130, height: 130,
              child: CustomPaint(painter: _MiniRadarPainter(scores: card.scores, accentColor: accent)),
            ),
          ),
          const SizedBox(height: 12),
          // Factor rows
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['H', 'E', 'X', 'A', 'C', 'O'].map((f) {
                final value = card.scores[f] ?? 50;
                final color = _factorColors[f]!;
                final label = isKo ? _factorLabelsKo[f]! : _factorLabelsEn[f]!;
                final desc = _getDesc(f, value, isKo);
                return Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: Center(child: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color))),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$label ${value.round()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                          Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.35))),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(value: value / 100, minHeight: 4, color: color, backgroundColor: color.withValues(alpha: 0.1)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MBTI: ${card.mbti}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w600)),
              Text('6가지 심리 유형', style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.2))),
            ],
          ),
        ],
      ),
    );
  }

  String _getDesc(String f, double v, bool isKo) {
    if (isKo) {
      return switch (f) {
        'H' => v >= 60 ? '진실하고 겸손한 성향' : '전략적이고 자신감 있는 성향',
        'E' => v >= 60 ? '감성적이고 공감 능력이 높음' : '침착하고 감정 조절이 좋음',
        'X' => v >= 60 ? '사교적이고 에너지가 넘침' : '독립적이고 깊이 있는 성향',
        'A' => v >= 60 ? '협력적이고 관대한 성향' : '비판적이고 원칙적인 성향',
        'C' => v >= 60 ? '체계적이고 신중한 성향' : '유연하고 즉흥적인 성향',
        'O' => v >= 60 ? '창의적이고 호기심이 많음' : '현실적이고 전통을 중시',
        _ => '',
      };
    } else {
      return switch (f) {
        'H' => v >= 60 ? 'Honest and humble' : 'Strategic and confident',
        'E' => v >= 60 ? 'Empathetic and sensitive' : 'Calm and composed',
        'X' => v >= 60 ? 'Social and energetic' : 'Independent and deep',
        'A' => v >= 60 ? 'Cooperative and generous' : 'Critical and principled',
        'C' => v >= 60 ? 'Organized and careful' : 'Flexible and spontaneous',
        'O' => v >= 60 ? 'Creative and curious' : 'Practical and traditional',
        _ => '',
      };
    }
  }
}

/// 미니 레이더 차트
class _MiniRadarPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color accentColor;

  _MiniRadarPainter({required this.scores, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 12;
    final factors = ['H', 'E', 'X', 'A', 'C', 'O'];

    Offset getPoint(int index, double value) {
      final angle = (2 * pi * index) / 6 - pi / 2;
      final r = (value / 100) * maxR;
      return Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
    }

    for (final level in [25.0, 50.0, 75.0, 100.0]) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final p = getPoint(i, level);
        if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: 0.06)..style = PaintingStyle.stroke..strokeWidth = 0.5);
    }

    final dataPath = Path();
    for (var i = 0; i < 6; i++) {
      final p = getPoint(i, scores[factors[i]] ?? 50);
      if (i == 0) { dataPath.moveTo(p.dx, p.dy); } else { dataPath.lineTo(p.dx, p.dy); }
    }
    dataPath.close();
    canvas.drawPath(dataPath, Paint()..color = accentColor.withValues(alpha: 0.2)..style = PaintingStyle.fill);
    canvas.drawPath(dataPath, Paint()..color = accentColor.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    for (var i = 0; i < 6; i++) {
      final p = getPoint(i, scores[factors[i]] ?? 50);
      canvas.drawCircle(p, 2.5, Paint()..color = _factorColors[factors[i]]!);
      final labelP = getPoint(i, 125);
      final tp = TextPainter(
        text: TextSpan(text: factors[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _factorColors[factors[i]]!)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(labelP.dx - tp.width / 2, labelP.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
