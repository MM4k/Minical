import 'package:flutter/material.dart';

/// User preferences persisted via SharedPreferences.
class AppSettings {
  /// 'en' or 'pt'.
  final String localeCode;

  /// A preset key (see AppThemes.presets) or 'custom'.
  final String themeId;

  /// ARGB color used when [themeId] == 'custom'.
  final int customColor;

  /// 'system', 'light' or 'dark'.
  final String themeModeName;

  /// Whether times are shown in 24-hour format (otherwise 12-hour AM/PM).
  final bool use24hTime;

  const AppSettings({
    this.localeCode = 'en',
    this.themeId = 'blue',
    this.customColor = 0xFF2563EB,
    this.themeModeName = 'system',
    this.use24hTime = true,
  });

  Locale get locale => Locale(localeCode);

  ThemeMode get themeMode => switch (themeModeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  AppSettings copyWith({
    String? localeCode,
    String? themeId,
    int? customColor,
    String? themeModeName,
    bool? use24hTime,
  }) =>
      AppSettings(
        localeCode: localeCode ?? this.localeCode,
        themeId: themeId ?? this.themeId,
        customColor: customColor ?? this.customColor,
        themeModeName: themeModeName ?? this.themeModeName,
        use24hTime: use24hTime ?? this.use24hTime,
      );
}
