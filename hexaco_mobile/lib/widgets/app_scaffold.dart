import 'package:flutter/material.dart';

import 'animated_background.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsets padding;
  final bool scroll;
  final ScrollController? controller;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.scroll = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset = appBar?.preferredSize.height ?? 0;
    final resolvedPadding = padding.copyWith(
      top: padding.top + (appBar == null ? 0 : topOffset + 8),
    );
    final content = Padding(padding: resolvedPadding, child: child);
    final framed = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: content,
      ),
    );

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
