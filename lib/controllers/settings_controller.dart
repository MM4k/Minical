import 'package:flutter/foundation.dart';

import '../data/settings_store.dart';
import '../models/app_settings.dart';

/// Holds the current [AppSettings] and persists every change.
class SettingsController extends ChangeNotifier {
  SettingsController(this._store, this._settings);

  final SettingsStore _store;
  AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> _apply(AppSettings next) async {
    _settings = next;
    notifyListeners();
    await _store.save(next);
  }

  Future<void> setLocale(String code) =>
      _apply(_settings.copyWith(localeCode: code));

  Future<void> setThemeId(String id) =>
      _apply(_settings.copyWith(themeId: id));

  Future<void> setCustomColor(int color) =>
      _apply(_settings.copyWith(themeId: 'custom', customColor: color));

  Future<void> setThemeMode(String mode) =>
      _apply(_settings.copyWith(themeModeName: mode));

  Future<void> setUse24hTime(bool value) =>
      _apply(_settings.copyWith(use24hTime: value));
}
