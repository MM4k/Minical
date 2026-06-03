import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_themes.dart';
import 'views/calendar/calendar_screen.dart';

class MinicalApp extends StatelessWidget {
  const MinicalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().settings;
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppThemes.themeFor(settings, Brightness.light),
      darkTheme: AppThemes.themeFor(settings, Brightness.dark),
      themeMode: settings.themeMode,
      home: const CalendarScreen(),
    );
  }
}
