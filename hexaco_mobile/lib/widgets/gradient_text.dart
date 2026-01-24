import 'package:flutter/material.dart';

import '../ui/app_tokens.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.gradient = AppGradients.textGradient,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: (style ?? Theme.of(context).textTheme.headlineSmall)
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
