import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Animation;

class LevelUpOverlay {
  static void show(
    BuildContext context, {
    required int level,
    required int currentXp,
    required int nextLevelXp,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (_) => _LevelUpDialog(
        level: level,
        currentXp: currentXp,
        nextLevelXp: nextLevelXp,
      ),
    );
  }
}

class _LevelUpDialog extends StatefulWidget {
  final int level;
  final int currentXp;
  final int nextLevelXp;

  const _LevelUpDialog({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog> {
  @override
  void initState() {
    super.initState();
    // Auto-close after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: RiveWidgetBuilder(
                  fileLoader: FileLoader.fromAsset(
                    'assets/rive/level_up.riv',
                    riveFactory: Factory.flutter,
                  ),
                  builder: (context, state) {
                    switch (state) {
                      case RiveLoaded loaded:
                        return RiveWidget(
                          controller: loaded.controller,
                          fit: Fit.contain,
                        );
                      case RiveLoading():
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF10B981),
                          ),
                        );
                      case RiveFailed():
                        return const Icon(
                          Icons.arrow_upward,
                          color: Color(0xFF10B981),
                          size: 80,
                        );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LEVEL ${widget.level}',
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LEVEL UP!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
