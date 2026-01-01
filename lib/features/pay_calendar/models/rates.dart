class Rates {
  const Rates({
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.jumpInRate,
    required this.weekStartWeekday,
    required this.localeCode,
  });

  final double hourlyWage;
  final double perRoomBonus;
  final double jumpInRate;
  final int weekStartWeekday;
  final String? localeCode;
}
