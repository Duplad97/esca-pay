class Rates {
  const Rates({
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.weekStartWeekday,
    required this.localeCode,
  });

  final double hourlyWage;
  final double perRoomBonus;
  final int weekStartWeekday;
  final String? localeCode;
}
