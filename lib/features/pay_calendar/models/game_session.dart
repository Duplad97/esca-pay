enum PaymentMethod { cash, card, transfer }

class GameSession {
  const GameSession({
    required this.roomName,
    required this.timeSlot,
    required this.guests,
    required this.paymentMethod,
    required this.satisfactionYes,
  });

  final String roomName;
  final String timeSlot;
  final int guests;
  final PaymentMethod paymentMethod;
  final bool satisfactionYes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'roomName': roomName,
        'timeSlot': timeSlot,
        'guests': guests,
        'paymentMethod': paymentMethod.name,
        'satisfactionYes': satisfactionYes,
      };

  static GameSession? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final roomName = raw['roomName'];
    final timeSlot = raw['timeSlot'];
    final guestsRaw = raw['guests'];
    final paymentMethodRaw = raw['paymentMethod'];
    final satisfactionYesRaw = raw['satisfactionYes'];

    if (roomName is! String ||
        timeSlot is! String ||
        guestsRaw is! num ||
        paymentMethodRaw is! String ||
        satisfactionYesRaw is! bool) {
      return null;
    }

    final pm = PaymentMethod.values.where((e) => e.name == paymentMethodRaw).firstOrNull;
    if (pm == null) return null;

    return GameSession(
      roomName: roomName,
      timeSlot: timeSlot,
      guests: guestsRaw.toInt(),
      paymentMethod: pm,
      satisfactionYes: satisfactionYesRaw,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

