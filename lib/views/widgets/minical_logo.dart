import 'package:flutter/material.dart';

/// The app logo: a solid rounded-square mark (in the theme's primary color)
/// with a minimal calendar glyph, optionally followed by the "Minical" wordmark.
class MinicalLogo extends StatelessWidget {
  const MinicalLogo({super.key, this.size = 32, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        Icons.event_rounded,
        color: scheme.onPrimary,
        size: size * 0.6,
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.32),
        Text(
          'Minical',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
