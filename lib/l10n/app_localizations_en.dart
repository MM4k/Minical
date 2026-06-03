// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Minical';

  @override
  String get today => 'Today';

  @override
  String get settings => 'Settings';

  @override
  String get viewMonth => 'Month';

  @override
  String get viewWeek => 'Week';

  @override
  String get timeFormat => 'Time format';

  @override
  String get hour24 => '24-hour';

  @override
  String get hour12 => '12-hour';

  @override
  String get newEvent => 'New event';

  @override
  String get editEvent => 'Edit event';

  @override
  String get addEvent => 'Add event';

  @override
  String get eventTitle => 'Title';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get category => 'Category';

  @override
  String get noCategory => 'None';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Start time';

  @override
  String get duration => 'Duration';

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatNever => 'Does not repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatYearly => 'Yearly';

  @override
  String get repeatUntil => 'Repeat until';

  @override
  String get repeatForever => 'Forever';

  @override
  String get clear => 'Clear';

  @override
  String get reminder => 'Reminder';

  @override
  String get reminderNone => 'None';

  @override
  String get reminderAtTime => 'At time of event';

  @override
  String reminderMinutesBefore(int count) {
    return '$count min before';
  }

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteEventTitle => 'Delete event?';

  @override
  String get deleteEventMessage => 'This will remove the event.';

  @override
  String get noEventsForDay => 'No events';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Portuguese (Brazil)';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeColor => 'Theme color';

  @override
  String get custom => 'Custom';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Name';

  @override
  String get color => 'Color';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String get deleteCategoryMessage =>
      'Events in this category will become uncategorized.';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get select => 'Select';
}
