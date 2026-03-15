import 'package:flutter/material.dart';
import 'dart:math' as math;

class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({super.key, required this.level, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final tier = _getTier(level);

    Widget badge = CustomPaint(
      size: Size(size, size),
      painter: _HexBadgePainter(tier.color),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );

    // Glow for level 10+
    if (level >= 10) {
      badge = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: tier.color.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: badge,
      );
    }

    // Shimmer for level 50+
    if (level >= 50) {
      badge = _ShimmerWrap(color: tier.color, child: badge);
    }

    return badge;
  }

  static _Tier _getTier(int level) {
    if (level >= 50) return _Tier(const Color(0xFFF59E0B), 'Gold');
    if (level >= 20) return _Tier(const Color(0xFF8B5CF6), 'Purple');
    if (level >= 10) return _Tier(const Color(0xFF3B82F6), 'Blue');
    if (level >= 5) return _Tier(const Color(0xFF10B981), 'Green');
    return _Tier(const Color(0xFF9CA3AF), 'Gray');
  }
}

class _Tier {
  final Color color;
  final String name;
  const _Tier(this.color, this.name);
}

class _HexBadgePainter extends CustomPainter {
  final Color color;
  _HexBadgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShimmerWrap extends StatefulWidget {
  final Color color;
  final Widget child;
  const _ShimmerWrap({required this.color, required this.child});

  @override
  State<_ShimmerWrap> createState() => _ShimmerWrapState();
}

class _ShimmerWrapState extends State<_ShimmerWrap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + 0.08 * math.sin(_ctrl.value * 2 * math.pi);
        return Transform.scale(scale: scale, child: widget.child);
      },
    );
  }
}

/// Nickname with level badge inline
class NicknameWithBadge extends StatelessWidget {
  final String nickname;
  final int level;
  final double badgeSize;
  final TextStyle? textStyle;

  const NicknameWithBadge({
    super.key,
    required this.nickname,
    required this.level,
    this.badgeSize = 20,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LevelBadge(level: level, size: badgeSize),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            nickname,
            style: textStyle ?? const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Time ago helper
String timeAgo(DateTime dateTime, {bool isKo = true}) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inDays > 365) return isKo ? '${diff.inDays ~/ 365}년 전' : '${diff.inDays ~/ 365}y';
  if (diff.inDays > 30) return isKo ? '${diff.inDays ~/ 30}개월 전' : '${diff.inDays ~/ 30}mo';
  if (diff.inDays > 0) return isKo ? '${diff.inDays}일 전' : '${diff.inDays}d';
  if (diff.inHours > 0) return isKo ? '${diff.inHours}시간 전' : '${diff.inHours}h';
  if (diff.inMinutes > 0) return isKo ? '${diff.inMinutes}분 전' : '${diff.inMinutes}m';
  return isKo ? '방금' : 'now';
}
