import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Animation;

import '../models/counselor_persona.dart';

/// 상담사 아바타 위젯 — Rive 애니메이션 + 이모지 폴백
class CounselorAvatar extends StatefulWidget {
  final CounselorPersona persona;
  final CounselorState state;
  final double size;

  const CounselorAvatar({
    super.key,
    required this.persona,
    this.state = CounselorState.idle,
    this.size = 80,
  });

  @override
  State<CounselorAvatar> createState() => _CounselorAvatarState();
}

class _CounselorAvatarState extends State<CounselorAvatar>
    with TickerProviderStateMixin {
  // Fallback animation controllers
  late final AnimationController _breathController;
  late final Animation<double> _breathAnimation;
  late final AnimationController _talkController;
  late final Animation<double> _talkAnimation;

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _talkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _talkAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _talkController, curve: Curves.easeInOut),
    );

    _updateFallbackState();
  }

  @override
  void didUpdateWidget(CounselorAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateFallbackState();
    }
  }

  void _updateFallbackState() {
    switch (widget.state) {
      case CounselorState.idle:
      case CounselorState.listening:
        _talkController.stop();
        _talkController.reset();
        if (!_breathController.isAnimating) {
          _breathController.repeat(reverse: true);
        }
        break;
      case CounselorState.talking:
        _talkController.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _talkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(widget.persona.accentColor);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.08),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: widget.size * 0.25,
            spreadRadius: widget.size * 0.03,
          ),
        ],
      ),
      child: ClipOval(
        child: RiveWidgetBuilder(
          fileLoader: FileLoader.fromAsset(
            widget.persona.riveAsset,
            riveFactory: Factory.flutter,
          ),
          builder: (context, state) {
            switch (state) {
              case RiveLoaded loaded:
                return RiveWidget(
                  controller: loaded.controller,
                  fit: Fit.cover,
                );
              case RiveLoading():
                return _buildEmojiFallback(accentColor);
              case RiveFailed():
                return _buildEmojiFallback(accentColor);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmojiFallback(Color accentColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnimation, _talkAnimation]),
      builder: (context, child) {
        final scale = widget.state == CounselorState.talking
            ? _talkAnimation.value
            : _breathAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Center(
            child: Text(
              widget.persona.emoji,
              style: TextStyle(fontSize: widget.size * 0.45),
            ),
          ),
        );
      },
    );
  }
}

/// 상담사 선택 카드용 미니 아바타 — Rive 정적 표시
class CounselorMiniAvatar extends StatelessWidget {
  final CounselorPersona persona;
  final double size;

  const CounselorMiniAvatar({
    super.key,
    required this.persona,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(persona.accentColor);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: size * 0.2,
          ),
        ],
      ),
      child: ClipOval(
        child: RiveWidgetBuilder(
          fileLoader: FileLoader.fromAsset(
            persona.riveAsset,
            riveFactory: Factory.flutter,
          ),
          builder: (context, state) {
            switch (state) {
              case RiveLoaded loaded:
                return RiveWidget(
                  controller: loaded.controller,
                  fit: Fit.cover,
                );
              case RiveLoading():
              case RiveFailed():
                return Center(
                  child: Text(
                    persona.emoji,
                    style: TextStyle(fontSize: size * 0.45),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
