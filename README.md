# Minical

A minimalist calendar built with Flutter — **desktop first (Windows)**, Android later.
Single codebase, **MVC** architecture, fully offline (local SQLite).

## Features

- Month grid with a detail list for the selected day
- Create / edit / delete events with **time** and **duration**
- **Categories** with solid colors
- **Recurrence**: daily, weekly, monthly, yearly (with an optional end date)
- **Local notification reminders** (e.g. 10 min before)
- **Languages**: English (default) and Brazilian Portuguese — switchable in Settings
- **Themes**: predefined solid colors + a custom color picker; light / dark / system

## Architecture (MVC)

```
lib/
  main.dart            bootstrap (DB, notifications, providers)
  app.dart             MaterialApp (theme + localization wiring)
  models/              Model: pure entities + recurrence logic
  data/                Model: SQLite (sqflite/ffi), repositories, settings & notifications
  controllers/         Controller: ChangeNotifier classes exposed via provider
  views/               View: calendar, event editor, settings (no business logic)
  theme/               solid-color ThemeData builder
  l10n/                generated localizations + app_en.arb / app_pt.arb
test/
  recurrence_test.dart unit tests for the recurrence expansion
```

## Requirements

- Flutter (stable) — developed on 3.44
- **Windows desktop build** also needs:
  - Visual Studio 2022 with the *Desktop development with C++* workload
  - **Developer Mode** enabled (Settings → System → For developers) so Flutter can
    create plugin symlinks
- **Android build** needs the Android SDK + a recent JDK (run `flutter doctor`)

## Running

```bash
flutter pub get
flutter test                 # runs the recurrence unit tests
flutter run -d windows       # desktop
flutter run -d <android-id>  # Android (device/emulator connected via adb)
```

## Localization

Strings live in `lib/l10n/app_en.arb` (template) and `lib/l10n/app_pt.arb`.
After editing them run `flutter gen-l10n` (or just build — generation is automatic).
