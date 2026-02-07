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
    final content = Padding(padding: padding, child: child);
    final framed = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: content,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 영역 (SafeArea 내부 — 상태바 아래에 자동 배치)
              if (appBar != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: appBar!,
                ),
              // 스크롤 가능한 메인 콘텐츠
              Expanded(
                child: scroll
                    ? SingleChildScrollView(controller: controller, child: framed)
                    : framed,
              ),
              // 하단 고정 배너 광고
              if (stickyBanner != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: stickyBanner!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
