import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../models/personality_card.dart';
import '../ui/app_tokens.dart';

/// Factor colors
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

/// SSR-style 3D hologram card with premium design
class HologramCard extends StatefulWidget {
  final PersonalityCard card;
  final bool isKo;
  final double width;
  final double height;
  final bool interactive;

  const HologramCard({
    super.key,
    required this.card,
    required this.isKo,
    this.width = 300,
    this.height = 420,
    this.interactive = true,
  });

  @override
  State<HologramCard> createState() => _HologramCardState();
}

class _HologramCardState extends State<HologramCard>
    with TickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _isFlipped = false;

  late AnimationController _flipController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _holoController;
  late AnimationController _springBackController;

  late Animation<double> _springBackX;
  late Animation<double> _springBackY;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.interactive) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      )..repeat();
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(reverse: true);
      _particleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5000),
      )..repeat();
      _holoController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 8000),
      )..repeat();
      _springBackController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _springBackX = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(
          parent: _springBackController,
          curve: Curves.elasticOut,
        ),
      );
      _springBackY = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(
          parent: _springBackController,
          curve: Curves.elasticOut,
        ),
      );
      _springBackController.addListener(() {
        setState(() {
          _rotateX = _springBackX.value;
          _rotateY = _springBackY.value;
        });
      });
    } else {
      // Non-interactive: create controllers but do NOT start them
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      );
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );
      _particleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5000),
      );
      _holoController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 8000),
      );
      _springBackController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _springBackX = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(
          parent: _springBackController,
          curve: Curves.elasticOut,
        ),
      );
      _springBackY = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(
          parent: _springBackController,
          curve: Curves.elasticOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _holoController.dispose();
    _springBackController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.interactive) return;
    _springBackController.stop();
    setState(() {
      _rotateY =
          (_rotateY + details.delta.dx * 0.5).clamp(-60.0, 60.0);
      _rotateX =
          (_rotateX - details.delta.dy * 0.5).clamp(-60.0, 60.0);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.interactive) return;
    _springBackX = Tween<double>(begin: _rotateX, end: 0).animate(
      CurvedAnimation(
        parent: _springBackController,
        curve: Curves.elasticOut,
      ),
    );
    _springBackY = Tween<double>(begin: _rotateY, end: 0).animate(
      CurvedAnimation(
        parent: _springBackController,
        curve: Curves.elasticOut,
      ),
    );
    _springBackController.forward(from: 0);
  }

  void _onTap() {
    if (!widget.interactive) return;
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
    final isHighRarity = widget.card.rarity == CardRarity.ssr ||
        widget.card.rarity == CardRarity.legend;
    final isLegend = widget.card.rarity == CardRarity.legend;

    Widget cardContent = AnimatedBuilder(
      animation: Listenable.merge([
        _flipController,
        _shimmerController,
        _pulseController,
        _particleController,
        _holoController,
      ]),
      builder: (context, child) {
        final flipAngle = _flipController.value * pi;
        final isFront = _flipController.value < 0.5;
        final pulseGlow = 0.5 + _pulseController.value * 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX * pi / 180)
            ..rotateY((_rotateY * pi / 180) + flipAngle),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                // Primary glow
                BoxShadow(
                  color: Color(config.glowColor).withValues(
                    alpha: pulseGlow * config.glowIntensity,
                  ),
                  blurRadius: isLegend
                      ? 50
                      : isHighRarity
                          ? 35
                          : 20,
                  spreadRadius: isLegend
                      ? 12
                      : isHighRarity
                          ? 6
                          : 3,
                ),
                // Secondary color glow for SSR+
                if (isHighRarity)
                  BoxShadow(
                    color: Color(widget.card.theme.secondaryAccent)
                        .withValues(alpha: pulseGlow * 0.25),
                    blurRadius: 70,
                    spreadRadius: 4,
                  ),
                // LEGEND: additional warm glow
                if (isLegend)
                  BoxShadow(
                    color: const Color(0xFFEF4444)
                        .withValues(alpha: pulseGlow * 0.12),
                    blurRadius: 80,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Card face
                  if (isFront)
                    Positioned.fill(
                      child: _PremiumCardFront(
                        card: widget.card,
                        isKo: widget.isKo,
                        shimmerValue: _shimmerController.value,
                        pulseValue: _pulseController.value,
                        holoValue: _holoController.value,
                        rotateX: _rotateX,
                        rotateY: _rotateY,
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(pi),
                        child: _CardBack(
                          card: widget.card,
                          isKo: widget.isKo,
                        ),
                      ),
                    ),

                  // Hologram sticker film (multi-layer)
                  _HologramStickerOverlay(
                    shimmerValue: _shimmerController.value,
                    holoValue: _holoController.value,
                    rotateX: _rotateX,
                    rotateY: _rotateY,
                    rarity: widget.card.rarity,
                  ),

                  // Diamond grid texture (like real hologram stickers)
                  if (widget.card.rarity != CardRarity.r)
                    _DiamondGridOverlay(
                      shimmerValue: _shimmerController.value,
                      rotateY: _rotateY,
                      rarity: widget.card.rarity,
                    ),

                  // Sparkle particles
                  if (widget.card.rarity != CardRarity.r)
                    _PremiumSparkles(
                      controller: _particleController,
                      rarity: widget.card.rarity,
                      accentColor:
                          Color(widget.card.theme.accentColor),
                    ),

                  // Rainbow edge border (SSR/LEGEND)
                  if (isHighRarity)
                    _AnimatedRainbowBorder(
                      shimmerValue: _shimmerController.value,
                      pulseValue: _pulseController.value,
                      rarity: widget.card.rarity,
                    ),

                  // R rarity: subtle shimmer on border
                  if (widget.card.rarity == CardRarity.r)
                    _RShimmerBorder(
                      shimmerValue: _shimmerController.value,
                      pulseValue: _pulseController.value,
                    ),

                  // Gold foil trim (LEGEND)
                  if (isLegend)
                    _GoldFoilTrim(
                      shimmerValue: _shimmerController.value,
                    ),

                  // Outer glow border
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(config.borderColor).withValues(
                            alpha:
                                0.4 + _pulseController.value * 0.4,
                          ),
                          width: isLegend
                              ? 2.5
                              : isHighRarity
                                  ? 2.0
                                  : 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Inner metallic inset border
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(
                        isLegend
                            ? 2.5
                            : isHighRarity
                                ? 2.0
                                : 1.5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              Colors.white.withValues(alpha: 0.15),
                          width: 1,
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
    );

    if (widget.interactive) {
      return GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTap: _onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// --- Premium Card Front -------------------------------------------------------

class _PremiumCardFront extends StatelessWidget {
  final PersonalityCard card;
  final bool isKo;
  final double shimmerValue;
  final double pulseValue;
  final double holoValue;
  final double rotateX;
  final double rotateY;

  const _PremiumCardFront({
    required this.card,
    required this.isKo,
    required this.shimmerValue,
    required this.pulseValue,
    required this.holoValue,
    required this.rotateX,
    required this.rotateY,
  });

  @override
  Widget build(BuildContext context) {
    final config = rarityConfigs[card.rarity]!;
    final accent = Color(card.theme.accentColor);
    final secondary = Color(card.theme.secondaryAccent);
    final isHighRarity =
        card.rarity == CardRarity.ssr || card.rarity == CardRarity.legend;
    final isLegend = card.rarity == CardRarity.legend;
    final isSSROrLegend = isHighRarity;

    // Parallax offsets for SSR/LEGEND
    final bgOffsetX = isSSROrLegend ? rotateY * 0.3 : 0.0;
    final bgOffsetY = isSSROrLegend ? rotateX * 0.3 : 0.0;
    final contentOffsetX = isSSROrLegend ? rotateY * -0.15 : 0.0;
    final contentOffsetY = isSSROrLegend ? rotateX * -0.15 : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              card.theme.gradientColors.map((c) => Color(c)).toList(),
        ),
      ),
      child: Stack(
        children: [
          // --- Background layer (parallax for SSR/LEGEND) ---
          Transform.translate(
            offset: Offset(bgOffsetX, bgOffsetY),
            child: Stack(
              children: [
                // Nebula/galaxy background texture
                Positioned.fill(
                  child: CustomPaint(
                    painter: _NebulaBackgroundPainter(
                      accent: accent,
                      secondary: secondary,
                      progress: holoValue,
                      intensity: isLegend
                          ? 0.15
                          : isHighRarity
                              ? 0.09
                              : 0.05,
                    ),
                  ),
                ),

                // Constellation pattern (SR+)
                if (card.rarity != CardRarity.r)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConstellationPainter(
                        color: accent,
                        progress: holoValue,
                        density: isLegend
                            ? 27
                            : isHighRarity
                                ? 18
                                : 11,
                      ),
                    ),
                  ),

                // R rarity: subtle diagonal stripe noise
                if (card.rarity == CardRarity.r)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DiagonalStripePainter(
                        color: Colors.white,
                        alpha: 0.02,
                      ),
                    ),
                  ),

                // Geometric frame for SSR+
                if (isHighRarity)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LuxuryFramePainter(
                        color: accent,
                        secondary: secondary,
                        progress: shimmerValue,
                        isLegend: isLegend,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // --- Content layer (parallax for SSR/LEGEND) ---
          Transform.translate(
            offset: Offset(contentOffsetX, contentOffsetY),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rarity badge + card number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RarityBadge(
                        rarity: card.rarity,
                        config: config,
                        accent: accent,
                        shimmerValue: shimmerValue,
                      ),
                      Text(
                        card.cardNumber,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.25),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),

                  // Central emoji with double glow aura
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer soft glow ring
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accent.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // Inner sharp glow ring
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accent.withValues(
                                  alpha: 0.2 + pulseValue * 0.08,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // SSR+: rotating light ring behind emoji
                        if (isHighRarity)
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CustomPaint(
                              painter: _RotatingLightRingPainter(
                                accent: accent,
                                secondary: secondary,
                                progress: shimmerValue,
                              ),
                            ),
                          ),

                        // Emoji
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                accent.withValues(
                                  alpha: 0.15 + pulseValue * 0.1,
                                ),
                                Colors.transparent,
                              ],
                              radius: 1.2,
                            ),
                          ),
                          child: Text(
                            card.emoji,
                            style: TextStyle(
                              fontSize: 72,
                              shadows: isHighRarity
                                  ? [
                                      Shadow(
                                        color: accent.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title with gradient ShaderMask for ALL rarities
                  Center(
                    child: ShaderMask(
                      shaderCallback: isLegend
                          ? (bounds) => LinearGradient(
                                colors: [
                                  const Color(0xFFFDE68A),
                                  Colors.white,
                                  const Color(0xFFFBBF24),
                                  Colors.white,
                                ],
                                stops: [
                                  (shimmerValue - 0.3).clamp(0.0, 1.0),
                                  shimmerValue.clamp(0.0, 1.0),
                                  (shimmerValue + 0.15)
                                      .clamp(0.0, 1.0),
                                  (shimmerValue + 0.3)
                                      .clamp(0.0, 1.0),
                                ],
                              ).createShader(bounds)
                          : (bounds) => LinearGradient(
                                colors: [accent, secondary],
                              ).createShader(bounds),
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
                          letterSpacing: isLegend ? 1 : 0,
                          shadows: [
                            if (isHighRarity)
                              Shadow(
                                color:
                                    accent.withValues(alpha: 0.5),
                                blurRadius: 12,
                              ),
                            Shadow(
                              color:
                                  Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quote (italic, 13pt)
                  Center(
                    child: Text(
                      '${card.quoteEmoji} ${isKo ? card.quoteKo : card.quoteEn}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),

                  // Top match -- premium design
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.06),
                          accent.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [accent, secondary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    accent.withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            card.topMatchName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.35),
                                secondary.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            '${card.topMatchSimilarity}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondary,
                              fontWeight: FontWeight.w800,
                            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color:
                                Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Text(
                          card.mbti,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Colors.white.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Text(
                        '6가지 심리 유형',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white.withValues(alpha: 0.25),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Overlay layer (hologram effects, stays fixed / no parallax) ---
          // This is empty as hologram effects are applied as siblings in HologramCard stack
        ],
      ),
    );
  }
}

// --- Rarity Badge --------------------------------------------------------------

class _RarityBadge extends StatelessWidget {
  final CardRarity rarity;
  final RarityConfig config;
  final Color accent;
  final double shimmerValue;

  const _RarityBadge({
    required this.rarity,
    required this.config,
    required this.accent,
    required this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    final isLegend = rarity == CardRarity.legend;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: _getBadgeGradient(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Color(config.borderColor)
              .withValues(alpha: isLegend ? 0.8 : 0.5),
          width: isLegend ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (rarity == CardRarity.ssr || isLegend)
            BoxShadow(
              color: accent.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          if (isLegend)
            BoxShadow(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(config.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          // Legend text with gold shimmer
          isLegend
              ? ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [
                      Color(0xFFFDE68A),
                      Color(0xFFFFFFFF),
                      Color(0xFFFBBF24),
                    ],
                    stops: [
                      (shimmerValue - 0.2).clamp(0.0, 1.0),
                      shimmerValue.clamp(0.0, 1.0),
                      (shimmerValue + 0.2).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                )
              : Text(
                  config.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 2,
                  ),
                ),
        ],
      ),
    );
  }

  LinearGradient _getBadgeGradient() {
    return switch (rarity) {
      CardRarity.legend => const LinearGradient(
          colors: [
            Color(0x88FBBF24),
            Color(0x66F59E0B),
            Color(0x55EF4444),
          ],
        ),
      CardRarity.ssr => LinearGradient(
          colors: [
            accent.withValues(alpha: 0.45),
            accent.withValues(alpha: 0.25),
          ],
        ),
      CardRarity.sr => LinearGradient(
          colors: [
            accent.withValues(alpha: 0.25),
            accent.withValues(alpha: 0.15),
          ],
        ),
      CardRarity.r => LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
    };
  }
}

// --- Hologram Sticker Overlay (multi-layer like real holographic stickers) -----

class _HologramStickerOverlay extends StatelessWidget {
  final double shimmerValue;
  final double holoValue;
  final double rotateX;
  final double rotateY;
  final CardRarity rarity;

  const _HologramStickerOverlay({
    required this.shimmerValue,
    required this.holoValue,
    required this.rotateX,
    required this.rotateY,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = switch (rarity) {
      CardRarity.legend => 0.22,
      CardRarity.ssr => 0.15,
      CardRarity.sr => 0.08,
      CardRarity.r => 0.03,
    };

    // Light source position based on tilt
    final lightX = 0.3 + rotateY / 50;
    final lightY = 0.2 - rotateX / 50;

    return Positioned.fill(
      child: Stack(
        children: [
          // Layer 1: Primary rainbow sweep with 12 stops for smoother rainbow
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      lightX * 2 - 1,
                      lightY * 2 - 1,
                    ),
                    end: Alignment(
                      -lightX * 2 + 1,
                      -lightY * 2 + 1,
                    ),
                    colors: [
                      Colors.transparent,
                      const Color(0xFFFF0080)
                          .withValues(alpha: intensity * 0.3),
                      const Color(0xFFFF1493)
                          .withValues(alpha: intensity * 0.5),
                      const Color(0xFFFF6B00)
                          .withValues(alpha: intensity * 0.6),
                      const Color(0xFFFFD700)
                          .withValues(alpha: intensity * 0.8),
                      const Color(0xFF88FF00)
                          .withValues(alpha: intensity * 0.6),
                      const Color(0xFF00FF88)
                          .withValues(alpha: intensity * 0.7),
                      const Color(0xFF00FFCC)
                          .withValues(alpha: intensity * 0.6),
                      const Color(0xFF00BFFF)
                          .withValues(alpha: intensity * 0.6),
                      const Color(0xFF4444FF)
                          .withValues(alpha: intensity * 0.5),
                      const Color(0xFF8A2BE2)
                          .withValues(alpha: intensity * 0.5),
                      Colors.transparent,
                    ],
                    stops: [
                      0.0,
                      (shimmerValue * 0.7).clamp(0.0, 0.08),
                      (shimmerValue * 0.7 + 0.04).clamp(0.0, 0.15),
                      (shimmerValue * 0.7 + 0.08).clamp(0.0, 0.25),
                      (shimmerValue * 0.7 + 0.12).clamp(0.0, 0.38),
                      (shimmerValue * 0.7 + 0.16).clamp(0.0, 0.48),
                      (shimmerValue * 0.7 + 0.20).clamp(0.0, 0.58),
                      (shimmerValue * 0.7 + 0.23).clamp(0.0, 0.65),
                      (shimmerValue * 0.7 + 0.26).clamp(0.0, 0.75),
                      (shimmerValue * 0.7 + 0.29).clamp(0.0, 0.85),
                      (shimmerValue * 0.7 + 0.32).clamp(0.0, 0.92),
                      1.0,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Layer 2: Secondary prismatic refraction (offset and time-shifted)
          if (rarity != CardRarity.r)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: intensity * 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(
                          -lightY * 2 + 1,
                          lightX * 2 - 1,
                        ),
                        end: Alignment(
                          lightY * 2 - 1,
                          -lightX * 2 + 1,
                        ),
                        colors: [
                          Colors.transparent,
                          const Color(0xFF00FFFF)
                              .withValues(alpha: 0.3),
                          const Color(0xFFFF00FF)
                              .withValues(alpha: 0.4),
                          const Color(0xFFFFFF00)
                              .withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: [
                          0.0,
                          (holoValue * 0.5).clamp(0.0, 0.3),
                          (holoValue * 0.5 + 0.15).clamp(0.0, 0.55),
                          (holoValue * 0.5 + 0.3).clamp(0.0, 0.8),
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Layer 3: Concentrated light spot (follows tilt) -- dynamic size
          if (rarity == CardRarity.ssr || rarity == CardRarity.legend)
            Positioned.fill(
              child: CustomPaint(
                painter: _HotSpotPainter(
                  lightX: lightX,
                  lightY: lightY,
                  intensity:
                      rarity == CardRarity.legend ? 0.35 : 0.2,
                  shimmerValue: shimmerValue,
                  tiltMagnitude: sqrt(
                    rotateX * rotateX + rotateY * rotateY,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Diamond Grid Overlay (like real hologram stickers) -----------------------

class _DiamondGridOverlay extends StatelessWidget {
  final double shimmerValue;
  final double rotateY;
  final CardRarity rarity;

  const _DiamondGridOverlay({
    required this.shimmerValue,
    required this.rotateY,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = switch (rarity) {
      CardRarity.legend => 0.06,
      CardRarity.ssr => 0.04,
      CardRarity.sr => 0.025,
      CardRarity.r => 0.0,
    };

    return Positioned.fill(
      child: CustomPaint(
        painter: _DiamondGridPainter(
          progress: shimmerValue,
          tilt: rotateY,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _DiamondGridPainter extends CustomPainter {
  final double progress;
  final double tilt;
  final double opacity;

  _DiamondGridPainter({
    required this.progress,
    required this.tilt,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    const spacing = 14.0;
    final offset = tilt * 0.3;

    // Diagonal lines (two directions)
    for (var i = -size.height; i < size.width + size.height; i += spacing) {
      final shimmerOffset = (progress * size.width * 2) - size.width;
      final dist = (i - shimmerOffset).abs();
      final localOpacity =
          dist < 80 ? opacity * (1.0 + (80 - dist) / 80 * 3) : opacity;

      paint.color = Colors.white
          .withValues(alpha: localOpacity.clamp(0.0, 0.2));
      canvas.drawLine(
        Offset(i + offset, 0),
        Offset(i - size.height + offset, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i - offset, 0),
        Offset(i + size.height - offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondGridPainter old) =>
      old.progress != progress || old.tilt != tilt;
}

// --- Hot Spot (concentrated light) with dynamic size --------------------------

class _HotSpotPainter extends CustomPainter {
  final double lightX;
  final double lightY;
  final double intensity;
  final double shimmerValue;
  final double tiltMagnitude;

  _HotSpotPainter({
    required this.lightX,
    required this.lightY,
    required this.intensity,
    required this.shimmerValue,
    required this.tiltMagnitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(lightX * size.width, lightY * size.height);
    // Dynamic radius: bigger when tilted more
    final tiltFactor = (tiltMagnitude / 60.0).clamp(0.0, 1.0);
    final radius = size.width * (0.4 + tiltFactor * 0.4);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          Colors.white.withValues(alpha: intensity),
          Colors.white.withValues(alpha: intensity * 0.3),
          Colors.transparent,
        ],
        [0.0, 0.3, 1.0],
      );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _HotSpotPainter old) =>
      old.lightX != lightX ||
      old.lightY != lightY ||
      old.tiltMagnitude != tiltMagnitude;
}

// --- R Shimmer Border ---------------------------------------------------------

class _RShimmerBorder extends StatelessWidget {
  final double shimmerValue;
  final double pulseValue;

  const _RShimmerBorder({
    required this.shimmerValue,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RShimmerBorderPainter(
          progress: shimmerValue,
          pulseValue: pulseValue,
        ),
      ),
    );
  }
}

class _RShimmerBorderPainter extends CustomPainter {
  final double progress;
  final double pulseValue;

  _RShimmerBorderPainter({
    required this.progress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final alpha = 0.08 + pulseValue * 0.06;

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: progress * 2 * pi,
        endAngle: progress * 2 * pi + 2 * pi,
        colors: [
          Color.fromRGBO(255, 255, 255, alpha),
          Color.fromRGBO(200, 200, 220, alpha * 1.5),
          Color.fromRGBO(255, 255, 255, alpha),
          Color.fromRGBO(180, 190, 210, alpha * 1.2),
          Color.fromRGBO(255, 255, 255, alpha),
        ],
        tileMode: TileMode.repeated,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _RShimmerBorderPainter old) =>
      old.progress != progress || old.pulseValue != pulseValue;
}

// --- Animated Rainbow Border ---------------------------------------------------

class _AnimatedRainbowBorder extends StatelessWidget {
  final double shimmerValue;
  final double pulseValue;
  final CardRarity rarity;

  const _AnimatedRainbowBorder({
    required this.shimmerValue,
    required this.pulseValue,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _RainbowBorderPainter(
          progress: shimmerValue,
          pulseValue: pulseValue,
          isLegend: rarity == CardRarity.legend,
        ),
      ),
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final double pulseValue;
  final bool isLegend;

  _RainbowBorderPainter({
    required this.progress,
    required this.pulseValue,
    required this.isLegend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final width = isLegend ? 2.5 + pulseValue * 0.5 : 1.8;
    final alpha =
        isLegend ? 0.7 + pulseValue * 0.3 : 0.4 + pulseValue * 0.2;

    final colors = isLegend
        ? [
            Color.fromRGBO(251, 191, 36, alpha),
            Color.fromRGBO(239, 68, 68, alpha),
            Color.fromRGBO(168, 85, 247, alpha),
            Color.fromRGBO(59, 130, 246, alpha),
            Color.fromRGBO(16, 185, 129, alpha),
            Color.fromRGBO(251, 191, 36, alpha),
          ]
        : [
            Color.fromRGBO(168, 85, 247, alpha),
            Color.fromRGBO(236, 72, 153, alpha),
            Color.fromRGBO(59, 130, 246, alpha),
            Color.fromRGBO(16, 185, 129, alpha),
            Color.fromRGBO(168, 85, 247, alpha),
          ];

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: progress * 2 * pi,
        endAngle: progress * 2 * pi + 2 * pi,
        colors: colors,
        tileMode: TileMode.repeated,
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawRRect(rect, paint);

    // LEGEND: inner glow edge
    if (isLegend) {
      final innerRect = RRect.fromRectAndRadius(
        const Offset(3, 3) & Size(size.width - 6, size.height - 6),
        const Radius.circular(14),
      );
      final glowPaint = Paint()
        ..shader = SweepGradient(
          startAngle: progress * 2 * pi + pi,
          endAngle: progress * 2 * pi + 3 * pi,
          colors: [
            const Color(0x00FBBF24),
            Color.fromRGBO(
              251,
              191,
              36,
              0.15 + pulseValue * 0.1,
            ),
            const Color(0x00FBBF24),
            Color.fromRGBO(
              239,
              68,
              68,
              0.1 + pulseValue * 0.08,
            ),
            const Color(0x00FBBF24),
          ],
          tileMode: TileMode.repeated,
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawRRect(innerRect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainbowBorderPainter old) =>
      old.progress != progress || old.pulseValue != pulseValue;
}

// --- Gold Foil Trim (LEGEND only) with finer pattern --------------------------

class _GoldFoilTrim extends StatelessWidget {
  final double shimmerValue;
  const _GoldFoilTrim({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GoldFoilPainter(progress: shimmerValue),
      ),
    );
  }
}

class _GoldFoilPainter extends CustomPainter {
  final double progress;
  _GoldFoilPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Corner flourishes
    final goldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final corners = [
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Offset(14, size.height - 14),
      Offset(size.width - 14, size.height - 14),
    ];

    for (var i = 0; i < corners.length; i++) {
      final c = corners[i];
      final dx = (i % 2 == 0) ? 1.0 : -1.0;
      final dy = (i < 2) ? 1.0 : -1.0;
      const len = 18.0;

      // Gold shimmer gradient on corner lines
      final shimmerPos = (progress + i * 0.25) % 1.0;
      goldPaint.shader = ui.Gradient.linear(
        c,
        Offset(c.dx + dx * len, c.dy + dy * len),
        [
          const Color(0x88FBBF24),
          const Color(0xCCFDE68A),
          const Color(0x88FBBF24),
        ],
        [
          (shimmerPos - 0.2).clamp(0.0, 1.0),
          shimmerPos.clamp(0.0, 1.0),
          (shimmerPos + 0.2).clamp(0.0, 1.0),
        ],
      );

      canvas.drawLine(c, Offset(c.dx + dx * len, c.dy), goldPaint);
      canvas.drawLine(c, Offset(c.dx, c.dy + dy * len), goldPaint);

      // Additional finer filigree lines
      final finePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..strokeCap = StrokeCap.round;
      final fineShimmerPos = (progress + i * 0.25 + 0.1) % 1.0;
      finePaint.shader = ui.Gradient.linear(
        c,
        Offset(c.dx + dx * len * 0.6, c.dy + dy * len * 0.6),
        [
          const Color(0x44FBBF24),
          const Color(0x88FDE68A),
          const Color(0x44FBBF24),
        ],
        [
          (fineShimmerPos - 0.2).clamp(0.0, 1.0),
          fineShimmerPos.clamp(0.0, 1.0),
          (fineShimmerPos + 0.2).clamp(0.0, 1.0),
        ],
      );
      // Inner diagonal filigree
      canvas.drawLine(
        c,
        Offset(c.dx + dx * len * 0.5, c.dy + dy * len * 0.5),
        finePaint,
      );
    }

    // Finer gold foil pattern: horizontal and vertical accent lines along edges
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3
      ..color = const Color(0x22FBBF24);

    // Top and bottom edge lines
    for (var i = 0; i < 8; i++) {
      final x = 30.0 + (size.width - 60) * i / 7;
      final shimmerDist =
          ((progress * size.width) - x).abs() / size.width;
      final lineAlpha =
          shimmerDist < 0.15 ? 0.12 * (1 - shimmerDist / 0.15) : 0.0;
      if (lineAlpha > 0.01) {
        edgePaint.color = Color.fromRGBO(251, 191, 36, lineAlpha);
        canvas.drawLine(
          Offset(x, 6),
          Offset(x, 10),
          edgePaint,
        );
        canvas.drawLine(
          Offset(x, size.height - 6),
          Offset(x, size.height - 10),
          edgePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GoldFoilPainter old) =>
      old.progress != progress;
}

// --- Premium Sparkle Particles -------------------------------------------------

class _PremiumSparkles extends StatelessWidget {
  final AnimationController controller;
  final CardRarity rarity;
  final Color accentColor;

  const _PremiumSparkles({
    required this.controller,
    required this.rarity,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _PremiumSparklesPainter(
              progress: controller.value,
              count: rarityConfigs[rarity]!.particleCount,
              color: accentColor,
              rarity: rarity,
            ),
          );
        },
      ),
    );
  }
}

class _PremiumSparklesPainter extends CustomPainter {
  final double progress;
  final int count;
  final Color color;
  final CardRarity rarity;

  _PremiumSparklesPainter({
    required this.progress,
    required this.count,
    required this.color,
    required this.rarity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42);
    final isLegend = rarity == CardRarity.legend;
    final isSSR = rarity == CardRarity.ssr;

    for (var i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final phase = (progress + i * (1.0 / count)) % 1.0;
      final y = baseY - sin(phase * pi) * 25;
      final opacity = sin(phase * pi) * (isLegend ? 0.95 : 0.75);
      final baseSize = rand.nextDouble() * 3 + 0.8;

      if (opacity <= 0.05) continue;

      final clampedOpacity = opacity.clamp(0.0, 1.0);

      if (isLegend) {
        // LEGEND: multi-color sparkles with stars
        final sparkleColor = switch (i % 5) {
          0 => const Color(0xFFFDE68A), // gold
          1 => const Color(0xFFFBBF24), // amber
          2 => const Color(0xFFEF4444), // red
          3 => const Color(0xFFA855F7), // purple
          _ => color,
        };

        if (i % 3 == 0) {
          _drawCrossStar(
            canvas,
            Offset(x, y),
            baseSize * 2.5,
            sparkleColor.withValues(alpha: clampedOpacity),
          );
        } else if (i % 5 == 0) {
          _drawDiamond(
            canvas,
            Offset(x, y),
            baseSize * 2,
            sparkleColor.withValues(alpha: clampedOpacity),
          );
        } else {
          canvas.drawCircle(
            Offset(x, y),
            baseSize,
            Paint()
              ..color =
                  sparkleColor.withValues(alpha: clampedOpacity)
              ..maskFilter =
                  MaskFilter.blur(BlurStyle.normal, baseSize),
          );
        }
      } else if (isSSR) {
        // SSR: cross-star sparkles
        final sparkleColor = i % 3 == 0 ? color : Colors.white;
        if (i % 4 == 0) {
          _drawCrossStar(
            canvas,
            Offset(x, y),
            baseSize * 2,
            sparkleColor.withValues(alpha: clampedOpacity),
          );
        } else {
          canvas.drawCircle(
            Offset(x, y),
            baseSize,
            Paint()
              ..color = sparkleColor.withValues(
                alpha: clampedOpacity * 0.7,
              )
              ..maskFilter = MaskFilter.blur(
                BlurStyle.normal,
                baseSize * 0.8,
              ),
          );
        }
      } else {
        // SR: simple glowing dots
        canvas.drawCircle(
          Offset(x, y),
          baseSize * 0.8,
          Paint()
            ..color =
                color.withValues(alpha: clampedOpacity * 0.5)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              baseSize * 0.6,
            ),
        );
      }
    }
  }

  void _drawCrossStar(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
    final path = Path();
    // 4-pointed star
    for (var i = 0; i < 4; i++) {
      final angle = pi / 2 * i;
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + cos(angle) * size,
        center.dy + sin(angle) * size,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.4),
    );
    // Center glow
    canvas.drawCircle(
      center,
      size * 0.3,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5),
    );
  }

  void _drawDiamond(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.5, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.5, center.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.3),
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumSparklesPainter old) =>
      old.progress != progress;
}

// --- Nebula Background (reduced blob alpha, increased blob count) -------------

class _NebulaBackgroundPainter extends CustomPainter {
  final Color accent;
  final Color secondary;
  final double progress;
  final double intensity;

  _NebulaBackgroundPainter({
    required this.accent,
    required this.secondary,
    required this.progress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(17);

    // Multiple overlapping nebula blobs (increased from 5 to 8)
    for (var i = 0; i < 8; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final r = 60 + rand.nextDouble() * 80;
      final phase = (progress + i * 0.125) % 1.0;
      final breathe = 0.7 + sin(phase * 2 * pi) * 0.3;

      final color = i % 2 == 0 ? accent : secondary;
      // Reduced alpha for subtlety (multiply intensity by 0.7)
      canvas.drawCircle(
        Offset(cx, cy),
        r * breathe,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(cx, cy),
            r * breathe,
            [
              color.withValues(alpha: intensity * breathe * 0.7),
              Colors.transparent,
            ],
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NebulaBackgroundPainter old) =>
      old.progress != progress;
}

// --- Constellation Pattern (50% more stars, longer lines) ---------------------

class _ConstellationPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int density;

  _ConstellationPainter({
    required this.color,
    required this.progress,
    required this.density,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(31);
    final stars = <Offset>[];

    for (var i = 0; i < density; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      stars.add(Offset(x, y));

      // Twinkling star
      final phase = (progress + i * (1.0 / density)) % 1.0;
      final twinkle =
          (sin(phase * 2 * pi) * 0.5 + 0.5).clamp(0.2, 1.0);
      final starSize = rand.nextDouble() * 1.5 + 0.5;

      canvas.drawCircle(
        Offset(x, y),
        starSize,
        Paint()..color = color.withValues(alpha: 0.15 * twinkle),
      );
    }

    // Connect nearby stars with faint lines (longer range: 130 instead of 100)
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 0.3;

    for (var i = 0; i < stars.length; i++) {
      for (var j = i + 1; j < stars.length; j++) {
        final dist = (stars[i] - stars[j]).distance;
        if (dist < 130) {
          canvas.drawLine(stars[i], stars[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.progress != progress;
}

// --- Diagonal Stripe Noise (R rarity) -----------------------------------------

class _DiagonalStripePainter extends CustomPainter {
  final Color color;
  final double alpha;

  _DiagonalStripePainter({required this.color, required this.alpha});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const spacing = 20.0;
    for (var i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripePainter old) => false;
}

// --- Luxury Frame (SSR/LEGEND) ------------------------------------------------

class _LuxuryFramePainter extends CustomPainter {
  final Color color;
  final Color secondary;
  final double progress;
  final bool isLegend;

  _LuxuryFramePainter({
    required this.color,
    required this.secondary,
    required this.progress,
    required this.isLegend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          color.withValues(alpha: isLegend ? 0.06 : 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(progress * pi * 0.05);

    // Concentric hexagons
    for (var ring = 1; ring <= 5; ring++) {
      final r = ring * 35.0;
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final angle = pi / 3 * i - pi / 2;
        final x = r * cos(angle);
        final y = r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    // Inner decorative circle
    if (isLegend) {
      canvas.drawCircle(
        Offset.zero,
        45,
        Paint()
          ..color =
              const Color(0xFFFBBF24).withValues(alpha: 0.04)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
      canvas.drawCircle(
        Offset.zero,
        90,
        Paint()
          ..color = secondary.withValues(alpha: 0.03)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LuxuryFramePainter old) =>
      old.progress != progress;
}

// --- Rotating Light Ring (SSR+ emoji background) ------------------------------

class _RotatingLightRingPainter extends CustomPainter {
  final Color accent;
  final Color secondary;
  final double progress;

  _RotatingLightRingPainter({
    required this.accent,
    required this.secondary,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: progress * 2 * pi,
        endAngle: progress * 2 * pi + 2 * pi,
        colors: [
          accent.withValues(alpha: 0.15),
          Colors.transparent,
          secondary.withValues(alpha: 0.12),
          Colors.transparent,
          accent.withValues(alpha: 0.15),
        ],
        tileMode: TileMode.repeated,
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius - 2, paint);
  }

  @override
  bool shouldRepaint(covariant _RotatingLightRingPainter old) =>
      old.progress != progress;
}

// --- Card Back -----------------------------------------------------------------

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
          colors:
              card.theme.gradientColors.map((c) => Color(c)).toList(),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: rarity label + card number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${config.icon} ${config.label}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(config.borderColor)
                      .withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                card.cardNumber,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.25),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // "Personality Stats" title with accent line
          Center(
            child: Column(
              children: [
                Text(
                  isKo ? '성격 분석' : 'Personality Stats',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 40,
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accent.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mini radar chart (6-factor hexagon, 130x130)
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _MiniRadarPainter(
                  scores: card.scores,
                  accentColor: accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 6 factor rows
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['H', 'E', 'X', 'A', 'C', 'O'].map((f) {
                final value = card.scores[f] ?? 50;
                final fColor = _factorColors[f]!;
                final label = isKo
                    ? _factorLabelsKo[f]!
                    : _factorLabelsEn[f]!;
                final desc = _getDesc(f, value, isKo);
                return Row(
                  children: [
                    // Factor icon
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: fColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: fColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Factor name, percent, description
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$label ${value.round()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            desc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress bar
                    SizedBox(
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: value / 100,
                          minHeight: 4,
                          color: fColor,
                          backgroundColor:
                              fColor.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Footer: MBTI + branding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MBTI: ${card.mbti}',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '6가지 심리 유형',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
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
        'A' =>
          v >= 60 ? 'Cooperative and generous' : 'Critical and principled',
        'C' =>
          v >= 60 ? 'Organized and careful' : 'Flexible and spontaneous',
        'O' =>
          v >= 60 ? 'Creative and curious' : 'Practical and traditional',
        _ => '',
      };
    }
  }
}

// --- Mini Radar Chart ----------------------------------------------------------

class _MiniRadarPainter extends CustomPainter {
  final Map<String, double> scores;
  final Color accentColor;

  _MiniRadarPainter({
    required this.scores,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 12;
    final factors = ['H', 'E', 'X', 'A', 'C', 'O'];

    Offset getPoint(int index, double value) {
      final angle = (2 * pi * index) / 6 - pi / 2;
      final r = (value / 100) * maxR;
      return Offset(
        center.dx + r * cos(angle),
        center.dy + r * sin(angle),
      );
    }

    // 3 concentric hexagonal grid levels (+ outer boundary = 4 total rings)
    for (final level in [25.0, 50.0, 75.0, 100.0]) {
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final p = getPoint(i, level);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }

    // Axis lines from center to each vertex
    for (var i = 0; i < 6; i++) {
      final p = getPoint(i, 100);
      canvas.drawLine(
        center,
        p,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..strokeWidth = 0.3,
      );
    }

    // Data polygon fill with accent color
    final dataPath = Path();
    for (var i = 0; i < 6; i++) {
      final p = getPoint(i, scores[factors[i]] ?? 50);
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = accentColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Data points and labels at each vertex
    for (var i = 0; i < 6; i++) {
      final p = getPoint(i, scores[factors[i]] ?? 50);
      canvas.drawCircle(
        p,
        2.5,
        Paint()..color = _factorColors[factors[i]]!,
      );
      final labelP = getPoint(i, 125);
      final tp = TextPainter(
        text: TextSpan(
          text: factors[i],
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: _factorColors[factors[i]]!,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelP.dx - tp.width / 2, labelP.dy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
