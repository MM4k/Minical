import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Persists [AppSettings] in SharedPreferences.
class SettingsStore {
  static const _kLocale = 'locale';
  static const _kThemeId = 'themeId';
  static const _kCustomColor = 'customColor';
  static const _kThemeMode = 'themeMode';
  static const _kUse24h = 'use24hTime';

  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = AppSettings();
    return AppSettings(
      localeCode: prefs.getString(_kLocale) ?? defaults.localeCode,
      themeId: prefs.getString(_kThemeId) ?? defaults.themeId,
      customColor: prefs.getInt(_kCustomColor) ?? defaults.customColor,
      themeModeName: prefs.getString(_kThemeMode) ?? defaults.themeModeName,
      use24hTime: prefs.getBool(_kUse24h) ?? defaults.use24hTime,
    );
  }

  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, settings.localeCode);
    await prefs.setString(_kThemeId, settings.themeId);
    await prefs.setInt(_kCustomColor, settings.customColor);
    await prefs.setString(_kThemeMode, settings.themeModeName);
    await prefs.setBool(_kUse24h, settings.use24hTime);
  }
}
