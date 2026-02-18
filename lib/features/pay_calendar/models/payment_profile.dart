import 'package:hive/hive.dart';

part 'payment_profile.g.dart';

@HiveType(typeId: 5)
class PaymentProfile {
  PaymentProfile({
    required this.id,
    required this.name,
    required this.hourlyWage,
    required this.perRoomBonus,
    required this.jumpInRate,
    required this.eventFine,
    this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double hourlyWage;

  @HiveField(3)
  final double perRoomBonus;

  @HiveField(4)
  final double jumpInRate;

  @HiveField(5)
  final double eventFine;

  @HiveField(6)
  final DateTime? createdAt;

  PaymentProfile copyWith({
    String? id,
    String? name,
    double? hourlyWage,
    double? perRoomBonus,
    double? jumpInRate,
    double? eventFine,
    DateTime? createdAt,
  }) {
    return PaymentProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      hourlyWage: hourlyWage ?? this.hourlyWage,
      perRoomBonus: perRoomBonus ?? this.perRoomBonus,
      jumpInRate: jumpInRate ?? this.jumpInRate,
      eventFine: eventFine ?? this.eventFine,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hourlyWage': hourlyWage,
      'perRoomBonus': perRoomBonus,
      'jumpInRate': jumpInRate,
      'eventFine': eventFine,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory PaymentProfile.fromJson(Map<String, dynamic> json) {
    return PaymentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      hourlyWage: (json['hourlyWage'] as num?)?.toDouble() ?? 0.0,
      perRoomBonus: (json['perRoomBonus'] as num?)?.toDouble() ?? 0.0,
      jumpInRate: (json['jumpInRate'] as num?)?.toDouble() ?? 0.0,
      eventFine: (json['eventFine'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
