// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'EscaPay';

  @override
  String get tagline => 'fizetés a drámáért';

  @override
  String get close => 'Bezárás';

  @override
  String get save => 'Mentés';

  @override
  String get clear => 'Törlés';

  @override
  String get done => 'Kész';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get settingsTooltip => 'Beállítások';

  @override
  String get hourlyWage => 'Órabér';

  @override
  String get perRoomBonus => 'Szobánkénti bónusz';

  @override
  String get jumpInRate => 'Beugró játék díja';

  @override
  String get eventFine => 'Rendezvény bónusz';

  @override
  String get ftPerHour => 'Ft / óra';

  @override
  String get ftPerRoom => 'Ft / szoba';

  @override
  String get ftPerJumpIn => 'Ft / beugró';

  @override
  String get ftPerEvent => 'Ft / rendezvény';

  @override
  String get weekStartsOn => 'A hét kezdete';

  @override
  String get usedForWeeklyTotals => 'Heti összesítéshez';

  @override
  String get language => 'Nyelv';

  @override
  String get languageSystem => 'Rendszer';

  @override
  String get languageEnglish => 'Angol';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get themesTooltip => 'Témák';

  @override
  String get theme_default => 'Alapértelmezett';

  @override
  String get theme_girly => 'Rózsaszín';

  @override
  String get theme_blue => 'Kék';

  @override
  String get theme_boy => 'Kék';

  @override
  String get previousMonthTooltip => 'Előző hónap';

  @override
  String get nextMonthTooltip => 'Következő hónap';

  @override
  String get today => 'Ma';

  @override
  String get select => 'Kijelölés';

  @override
  String get summary => 'Összegzés';

  @override
  String selectedCount(int count) {
    return '$count kijelölve';
  }

  @override
  String get weekly => 'Heti';

  @override
  String get monthly => 'Havi';

  @override
  String get selectedDay => 'Kiválasztott nap';

  @override
  String get dayShort => 'Nap';

  @override
  String get previousDayTooltip => 'Előző nap';

  @override
  String get nextDayTooltip => 'Következő nap';

  @override
  String hoursRoomsLine(String hours, int rooms) {
    return 'Óra: $hours • Szoba: $rooms';
  }

  @override
  String hoursRoomsEventsLine(String hours, int rooms, int events) {
    return 'Óra: $hours • Szoba: $rooms • Rendezvény: $events';
  }

  @override
  String get noEntryYetHint => 'Nincs bejegyzés';

  @override
  String get sessions => 'Játékok';

  @override
  String get editDay => 'Nap szerkesztése';

  @override
  String get hoursWorkedTitle => 'Ledolgozott órák';

  @override
  String get hoursWorkedSubtitle => 'túlél(t) órák (tisztelettel)';

  @override
  String get startTimeTitle => 'Kezdési idő';

  @override
  String get startTimeSubtitle => 'amikor bejelentkezett';

  @override
  String get endTimeTitle => 'Befejezési idő';

  @override
  String get endTimeSubtitle => 'amikor kijelentkezett';

  @override
  String get timeTrackingCalculation => 'Automatikusan számítva';

  @override
  String get selectStartTime => 'Válassz kezdési időpontot';

  @override
  String get selectEndTime => 'Válassz befejezési időpontot';

  @override
  String hoursCalculatedFromTime(String hours) {
    return 'Órák az időből számítva: $hours';
  }

  @override
  String get roomsHostedTitle => 'Levezetett szobák';

  @override
  String get roomsHostedSubtitleNone => 'mai szobák';

  @override
  String roomsHostedSubtitleWithSessions(int count) {
    return 'mentett játékok: $count';
  }

  @override
  String eventsToday(int count) {
    return 'Rendezvények ma: $count';
  }

  @override
  String roomsSessionsMismatch(int sessions, int rooms) {
    return 'Figyi: játékok ($sessions) ≠ szobák ($rooms).';
  }

  @override
  String get decreaseTooltip => 'Csökkentés';

  @override
  String get increaseTooltip => 'Növelés';

  @override
  String get selectAtLeastOneDay => 'Válassz ki legalább egy napot';

  @override
  String get selectedDaysTitle => 'Kijelölt napok';

  @override
  String get totalWage => 'Összes bér';

  @override
  String xDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nap',
      one: '1 nap',
    );
    return '$_temp0';
  }

  @override
  String get hours => 'Óra';

  @override
  String get rooms => 'Szoba';

  @override
  String get events => 'Rendezvények';

  @override
  String get eventsSheetEmpty =>
      'Még nincs Rendezvény.\nNyomd meg: \"Rendezvény hozzáadása\".';

  @override
  String get selectEventTime => 'Rendezvény időpontjának megadása';

  @override
  String get sessionsSheetEmpty =>
      'Még nincs Játék.\nNyomd meg: „Játék hozzáadása”.';

  @override
  String get addSession => 'Játék hozzáadása';

  @override
  String get addEvent => 'Rendezvény hozzáadása';

  @override
  String get saveSession => 'Játék mentése';

  @override
  String sessionNumber(int number) {
    return 'Játék #$number';
  }

  @override
  String get remove => 'Törlés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get finishCurrentSessionFirst => 'Előbb fejezd be az aktuális játékot';

  @override
  String get pickRoomNameToSave => 'Válassz szobanevet a mentéshez';

  @override
  String get pickTimeToSave => 'Válassz időpontot a mentéshez';

  @override
  String get roomName => 'Szoba neve';

  @override
  String get time => 'Időpont';

  @override
  String get guests => 'Vendégek';

  @override
  String get payment => 'Fizetési mód';

  @override
  String get paymentCash => 'Készpénz';

  @override
  String get paymentCard => 'Kártya';

  @override
  String get paymentTransfer => 'Átutalás';

  @override
  String get satisfaction => 'Elégedettség';

  @override
  String get yes => 'Igen';

  @override
  String get no => 'Nem';

  @override
  String guestsChip(int count) {
    return '$count vendég';
  }

  @override
  String get satisfied => 'Elégedett';

  @override
  String get notSatisfied => 'Nem elégedett';

  @override
  String get benefits => 'Egyéb juttatások';

  @override
  String benefitsSubtitle(int count, double total) {
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '$count juttatás • $totalString Ft összesen';
  }

  @override
  String get benefitsSheetEmpty =>
      'Még nincsenek juttatások.\nAdj hozzá juttatásokat a extra jövedelem nyomon követéséhez.';

  @override
  String get benefitName => 'Juttatás neve';

  @override
  String benefitAmount(double amount) {
    final intl.NumberFormat amountNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String amountString = amountNumberFormat.format(amount);

    return '+$amountString Ft';
  }

  @override
  String get amount => 'Összeg';

  @override
  String get add => 'Hozzáad';

  @override
  String get pickARoom => 'Szoba választása';

  @override
  String get search => 'Keresés';

  @override
  String get jumpIn => 'Beugró';

  @override
  String get sessionType => 'Játék típusa';

  @override
  String get sessionTypeNormal => 'Normál';

  @override
  String get tapToFlap => 'Koppints a repüléshez';

  @override
  String get gameOverTapToRetry => 'Vége — koppints az újrakezdéshez';

  @override
  String get scoreLabel => 'Pont';

  @override
  String get bestLabel => 'Rekord';

  @override
  String get weeklyPaymentSummaryTitle => 'Heti összegzés';

  @override
  String get weeklyPaymentSummaryBody =>
      'Szia, elküldted már a heti összegzésedet?';

  @override
  String get weeklyPaymentSummaryConfirm => 'Elküldtem';

  @override
  String get weeklyPaymentSummaryDialogTitle => 'Összegzés megerősítése';

  @override
  String get weeklyPaymentSummaryDialogMessage =>
      'Elküldted már a heti összegzésedet?';

  @override
  String get weeklyPaymentSummaryDialogConfirm => 'Elküldtem';

  @override
  String get weeklyPaymentSummaryDialogCancel => 'Még nem';

  @override
  String get weeklyPaymentSummaryCheckboxLabel =>
      'Elküldted a heti összegzésedet';
}
