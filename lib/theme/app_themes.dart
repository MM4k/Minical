import 'package:flutter/material.dart';

import '../models/app_settings.dart';

/// Builds the app [ThemeData] from the user's chosen solid color.
///
/// All colors are solid (Material 3 tonal palettes derived from a seed) — no
/// gradients are used anywhere in the UI.
class AppThemes {
  AppThemes._();

  /// Predefined solid theme colors, keyed by a stable id stored in settings.
  static const Map<String, Color> presets = {
    'blue': Color(0xFF2563EB),
    'green': Color(0xFF16A34A),
    'purple': Color(0xFF7C3AED),
    'orange': Color(0xFFEA580C),
    'teal': Color(0xFF0D9488),
    'rose': Color(0xFFE11D48),
  };

  /// Stable display order for the preset swatches.
  static const List<String> presetOrder = [
    'blue',
    'green',
    'purple',
    'orange',
    'teal',
    'rose',
  ];

  static Color seedFor(AppSettings settings) => settings.themeId == 'custom'
      ? Color(settings.customColor)
      : (presets[settings.themeId] ?? presets['blue']!);

  static ThemeData themeFor(AppSettings settings, Brightness brightness) {
    final seed = seedFor(settings);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      // Keep the app bar a solid, fixed color — no tint change when content
      // scrolls underneath it.
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
