// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VpnSessionAdapter extends TypeAdapter<VpnSession> {
  @override
  final int typeId = 1;

  @override
  VpnSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VpnSession(
      startTime: fields[0] as DateTime,
      duration: Duration(seconds: fields[1] as int),
    );
  }

  @override
  void write(BinaryWriter writer, VpnSession obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.durationSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VpnSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
