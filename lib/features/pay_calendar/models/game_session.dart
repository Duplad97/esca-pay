enum SessionType { normal, jumpIn }
enum PaymentMethod { cash, card, transfer }

class GameSession {
  const GameSession({
    required this.type,
    required this.roomName,
    required this.timeSlot,
    required this.guests,
    required this.paymentMethod,
    required this.satisfactionYes,
  });

  final SessionType type;
  final String roomName;
  final String timeSlot;
  final int guests;
  final PaymentMethod paymentMethod;
  final bool satisfactionYes;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.name,
        'roomName': roomName,
        'timeSlot': timeSlot,
        'guests': guests,
        'paymentMethod': paymentMethod.name,
        'satisfactionYes': satisfactionYes,
      };

  static GameSession? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final typeRaw = raw['type'] ?? 'normal'; // default to normal for backwards compatibility
    final roomName = raw['roomName'];
    final timeSlot = raw['timeSlot'];
    final guestsRaw = raw['guests'];
    final paymentMethodRaw = raw['paymentMethod'];
    final satisfactionYesRaw = raw['satisfactionYes'];

    if (typeRaw is! String ||
        roomName is! String ||
        timeSlot is! String ||
        guestsRaw is! num ||
        paymentMethodRaw is! String ||
        satisfactionYesRaw is! bool) {
      return null;
    }

    // Handle backwards compatibility: old "beugro" maps to new "jumpIn"
    final normalizedType = typeRaw == 'beugro' ? 'jumpIn' : typeRaw;
    final sessionType = SessionType.values.where((e) => e.name == normalizedType).firstOrNull ?? SessionType.normal;
    final pm = PaymentMethod.values.where((e) => e.name == paymentMethodRaw).firstOrNull;
    if (pm == null) return null;

    return GameSession(
      type: sessionType,
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

