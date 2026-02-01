import 'package:flutter/material.dart';

import 'animated_background.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsets padding;
  final bool scroll;
  final ScrollController? controller;
  final Widget? stickyBanner;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.scroll = true,
    this.controller,
    this.stickyBanner,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset = appBar?.preferredSize.height ?? 0;

    // 배너가 있을 때는 상단 패딩을 최소화
    final resolvedPadding = stickyBanner != null
        ? padding.copyWith(top: 4)
        : padding.copyWith(
            top: padding.top + (appBar == null ? 0 : topOffset + 8),
          );
    final content = Padding(padding: resolvedPadding, child: child);
    final framed = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: content,
      ),
    );

    if (stickyBanner != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: appBar != null,
        appBar: appBar,
        body: AnimatedBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: stickyBanner!,
                ),
                Expanded(
                  child: scroll
                      ? SingleChildScrollView(controller: controller, child: framed)
                      : framed,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      body: AnimatedBackground(
        child: SafeArea(
          child: scroll
              ? SingleChildScrollView(controller: controller, child: framed)
              : framed,
        ),
      ),
    );
  }
}
