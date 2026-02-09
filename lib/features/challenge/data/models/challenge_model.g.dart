// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 1;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      duration: fields[2] as int,
      threatLevel: fields[3] as String,
      consequenceType: fields[4] as String,
      specificConsequence: fields[5] as String,
      startDate: fields[6] as DateTime,
      completedDates: (fields[7] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.threatLevel)
      ..writeByte(4)
      ..write(obj.consequenceType)
      ..writeByte(5)
      ..write(obj.specificConsequence)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.completedDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
