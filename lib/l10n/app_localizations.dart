import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EscaPay'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'get paid for the drama'**
  String get tagline;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @hourlyWage.
  ///
  /// In en, this message translates to:
  /// **'Hourly wage'**
  String get hourlyWage;

  /// No description provided for @perRoomBonus.
  ///
  /// In en, this message translates to:
  /// **'Per-room bonus'**
  String get perRoomBonus;

  /// No description provided for @jumpInRate.
  ///
  /// In en, this message translates to:
  /// **'Jump-in game rate'**
  String get jumpInRate;

  /// No description provided for @ftPerHour.
  ///
  /// In en, this message translates to:
  /// **'Ft / hour'**
  String get ftPerHour;

  /// No description provided for @ftPerRoom.
  ///
  /// In en, this message translates to:
  /// **'Ft / room'**
  String get ftPerRoom;

  /// No description provided for @ftPerJumpIn.
  ///
  /// In en, this message translates to:
  /// **'Ft / jump-in'**
  String get ftPerJumpIn;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartsOn;

  /// No description provided for @usedForWeeklyTotals.
  ///
  /// In en, this message translates to:
  /// **'Used for weekly totals'**
  String get usedForWeeklyTotals;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHungarian.
  ///
  /// In en, this message translates to:
  /// **'Hungarian'**
  String get languageHungarian;

  /// No description provided for @themesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themesTooltip;

  /// No description provided for @theme_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get theme_default;

  /// No description provided for @theme_girly.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get theme_girly;

  /// No description provided for @theme_boy.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get theme_boy;

  /// No description provided for @previousMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonthTooltip;

  /// No description provided for @nextMonthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonthTooltip;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @selectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected day'**
  String get selectedDay;

  /// No description provided for @previousDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDayTooltip;

  /// No description provided for @nextDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDayTooltip;

  /// No description provided for @hoursRoomsLine.
  ///
  /// In en, this message translates to:
  /// **'Hours: {hours} • Rooms: {rooms}'**
  String hoursRoomsLine(String hours, int rooms);

  /// No description provided for @noEntryYetHint.
  ///
  /// In en, this message translates to:
  /// **'No entry yet — long-press a day to edit'**
  String get noEntryYetHint;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @editDay.
  ///
  /// In en, this message translates to:
  /// **'Edit day'**
  String get editDay;

  /// No description provided for @hoursWorkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Hours worked'**
  String get hoursWorkedTitle;

  /// No description provided for @hoursWorkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'hours survived (respectfully)'**
  String get hoursWorkedSubtitle;

  /// No description provided for @startTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTimeTitle;

  /// No description provided for @startTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'when you clocked in'**
  String get startTimeSubtitle;

  /// No description provided for @endTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTimeTitle;

  /// No description provided for @endTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'when you clocked out'**
  String get endTimeSubtitle;

  /// No description provided for @timeTrackingCalculation.
  ///
  /// In en, this message translates to:
  /// **'Automatically calculated'**
  String get timeTrackingCalculation;

  /// No description provided for @selectStartTime.
  ///
  /// In en, this message translates to:
  /// **'Select start time'**
  String get selectStartTime;

  /// No description provided for @selectEndTime.
  ///
  /// In en, this message translates to:
  /// **'Select end time'**
  String get selectEndTime;

  /// No description provided for @hoursCalculatedFromTime.
  ///
  /// In en, this message translates to:
  /// **'Hours calculated from time: {hours}'**
  String hoursCalculatedFromTime(String hours);

  /// No description provided for @roomsHostedTitle.
  ///
  /// In en, this message translates to:
  /// **'Rooms hosted'**
  String get roomsHostedTitle;

  /// No description provided for @roomsHostedSubtitleNone.
  ///
  /// In en, this message translates to:
  /// **'rooms ran today'**
  String get roomsHostedSubtitleNone;

  /// No description provided for @roomsHostedSubtitleWithSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions saved: {count}'**
  String roomsHostedSubtitleWithSessions(int count);

  /// No description provided for @roomsSessionsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Heads up: sessions ({sessions}) ≠ rooms hosted ({rooms}).'**
  String roomsSessionsMismatch(int sessions, int rooms);

  /// No description provided for @decreaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decreaseTooltip;

  /// No description provided for @increaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increaseTooltip;

  /// No description provided for @selectAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day'**
  String get selectAtLeastOneDay;

  /// No description provided for @selectedDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected days'**
  String get selectedDaysTitle;

  /// No description provided for @totalWage.
  ///
  /// In en, this message translates to:
  /// **'Total wage'**
  String get totalWage;

  /// No description provided for @xDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String xDays(int count);

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @sessionsSheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet.\nTap “Add session”.'**
  String get sessionsSheetEmpty;

  /// No description provided for @addSession.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get addSession;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get saveSession;

  /// No description provided for @sessionNumber.
  ///
  /// In en, this message translates to:
  /// **'Session #{number}'**
  String sessionNumber(int number);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @finishCurrentSessionFirst.
  ///
  /// In en, this message translates to:
  /// **'Finish the current session first'**
  String get finishCurrentSessionFirst;

  /// No description provided for @pickRoomNameToSave.
  ///
  /// In en, this message translates to:
  /// **'Pick a room name to save this session'**
  String get pickRoomNameToSave;

  /// No description provided for @pickTimeToSave.
  ///
  /// In en, this message translates to:
  /// **'Pick a time to save this session'**
  String get pickTimeToSave;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room name'**
  String get roomName;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @guests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get guests;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentCard;

  /// No description provided for @paymentTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get paymentTransfer;

  /// No description provided for @satisfaction.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction'**
  String get satisfaction;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @guestsChip.
  ///
  /// In en, this message translates to:
  /// **'{count} guests'**
  String guestsChip(int count);

  /// No description provided for @satisfied.
  ///
  /// In en, this message translates to:
  /// **'Satisfied'**
  String get satisfied;

  /// No description provided for @notSatisfied.
  ///
  /// In en, this message translates to:
  /// **'Not satisfied'**
  String get notSatisfied;

  /// No description provided for @pickARoom.
  ///
  /// In en, this message translates to:
  /// **'Pick a room'**
  String get pickARoom;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @jumpIn.
  ///
  /// In en, this message translates to:
  /// **'Jump-in game'**
  String get jumpIn;

  /// No description provided for @sessionType.
  ///
  /// In en, this message translates to:
  /// **'Session type'**
  String get sessionType;

  /// No description provided for @sessionTypeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get sessionTypeNormal;

  /// No description provided for @tapToFlap.
  ///
  /// In en, this message translates to:
  /// **'Tap to flap'**
  String get tapToFlap;

  /// No description provided for @gameOverTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Game over — tap to retry'**
  String get gameOverTapToRetry;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreLabel;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
