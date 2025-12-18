import 'game_session.dart';

class DayEntry {
  const DayEntry({
    required this.hours,
    required this.rooms,
    this.sessions = const <GameSession>[],
  });

  final double hours;
  final int rooms;
  final List<GameSession> sessions;

  bool get isEmpty => hours <= 0 && rooms <= 0 && sessions.isEmpty;

  double earnings({required double hourlyWage, required double perRoomBonus}) {
    return (hours * hourlyWage) + (rooms * perRoomBonus);
  }
}
