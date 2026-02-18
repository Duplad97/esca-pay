// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentProfileAdapter extends TypeAdapter<PaymentProfile> {
  @override
  final int typeId = 5;

  @override
  PaymentProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      hourlyWage: fields[2] as double,
      perRoomBonus: fields[3] as double,
      jumpInRate: fields[4] as double,
      eventFine: fields[5] as double,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hourlyWage)
      ..writeByte(3)
      ..write(obj.perRoomBonus)
      ..writeByte(4)
      ..write(obj.jumpInRate)
      ..writeByte(5)
      ..write(obj.eventFine)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
