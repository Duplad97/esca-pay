// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EscaPay';

  @override
  String get tagline => 'get paid for the drama';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get hourlyWage => 'Hourly wage';

  @override
  String get perRoomBonus => 'Per-room bonus';

  @override
  String get jumpInRate => 'Jump-in game rate';

  @override
  String get ftPerHour => 'Ft / hour';

  @override
  String get ftPerRoom => 'Ft / room';

  @override
  String get ftPerJumpIn => 'Ft / jump-in';

  @override
  String get weekStartsOn => 'Week starts on';

  @override
  String get usedForWeeklyTotals => 'Used for weekly totals';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Hungarian';

  @override
  String get themesTooltip => 'Themes';

  @override
  String get theme_default => 'Default';

  @override
  String get theme_girly => 'Pink';

  @override
  String get theme_boy => 'Blue';

  @override
  String get previousMonthTooltip => 'Previous month';

  @override
  String get nextMonthTooltip => 'Next month';

  @override
  String get today => 'Today';

  @override
  String get select => 'Select';

  @override
  String get summary => 'Summary';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get selectedDay => 'Selected day';

  @override
  String get previousDayTooltip => 'Previous day';

  @override
  String get nextDayTooltip => 'Next day';

  @override
  String hoursRoomsLine(String hours, int rooms) {
    return 'Hours: $hours • Rooms: $rooms';
  }

  @override
  String get noEntryYetHint => 'No entry yet — long-press a day to edit';

  @override
  String get sessions => 'Sessions';

  @override
  String get editDay => 'Edit day';

  @override
  String get hoursWorkedTitle => 'Hours worked';

  @override
  String get hoursWorkedSubtitle => 'hours survived (respectfully)';

  @override
  String get roomsHostedTitle => 'Rooms hosted';

  @override
  String get roomsHostedSubtitleNone => 'rooms ran today';

  @override
  String roomsHostedSubtitleWithSessions(int count) {
    return 'sessions saved: $count';
  }

  @override
  String roomsSessionsMismatch(int sessions, int rooms) {
    return 'Heads up: sessions ($sessions) ≠ rooms hosted ($rooms).';
  }

  @override
  String get decreaseTooltip => 'Decrease';

  @override
  String get increaseTooltip => 'Increase';

  @override
  String get selectAtLeastOneDay => 'Select at least one day';

  @override
  String get selectedDaysTitle => 'Selected days';

  @override
  String get totalWage => 'Total wage';

  @override
  String xDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get hours => 'Hours';

  @override
  String get rooms => 'Rooms';

  @override
  String get sessionsSheetEmpty => 'No sessions yet.\nTap “Add session”.';

  @override
  String get addSession => 'Add session';

  @override
  String get saveSession => 'Save session';

  @override
  String sessionNumber(int number) {
    return 'Session #$number';
  }

  @override
  String get remove => 'Remove';

  @override
  String get edit => 'Edit';

  @override
  String get finishCurrentSessionFirst => 'Finish the current session first';

  @override
  String get pickRoomNameToSave => 'Pick a room name to save this session';

  @override
  String get pickTimeToSave => 'Pick a time to save this session';

  @override
  String get roomName => 'Room name';

  @override
  String get time => 'Time';

  @override
  String get guests => 'Guests';

  @override
  String get payment => 'Payment';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentCard => 'Card';

  @override
  String get paymentTransfer => 'Transfer';

  @override
  String get satisfaction => 'Satisfaction';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String guestsChip(int count) {
    return '$count guests';
  }

  @override
  String get satisfied => 'Satisfied';

  @override
  String get notSatisfied => 'Not satisfied';

  @override
  String get pickARoom => 'Pick a room';

  @override
  String get search => 'Search';

  @override
  String get jumpIn => 'Jump-in game';

  @override
  String get sessionType => 'Session type';

  @override
  String get sessionTypeNormal => 'Normal';

  @override
  String get tapToFlap => 'Tap to flap';

  @override
  String get gameOverTapToRetry => 'Game over — tap to retry';

  @override
  String get scoreLabel => 'Score';

  @override
  String get bestLabel => 'Best';
}
