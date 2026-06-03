import 'package:intl/intl.dart';

/// Time-of-day format that honors the user's 24h/12h preference.
DateFormat timeFormatOf(String localeName, {required bool use24h}) =>
    use24h ? DateFormat.Hm(localeName) : DateFormat('h:mm a', localeName);

/// Compact hour-label format for the week timetable gutter.
DateFormat hourLabelFormatOf(String localeName, {required bool use24h}) =>
    use24h ? DateFormat.Hm(localeName) : DateFormat('h a', localeName);
