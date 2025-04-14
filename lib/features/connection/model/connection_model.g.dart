// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VpnConnectionStateAdapter extends TypeAdapter<VpnConnectionState> {
  @override
  final int typeId = 0;

  @override
  VpnConnectionState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VpnConnectionState(
      isConnected: fields[0] as bool,
      isConnecting: fields[1] as bool,
      duration: fields[2] as Duration,
      lastConnection: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VpnConnectionState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isConnected)
      ..writeByte(1)
      ..write(obj.isConnecting)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.lastConnection);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VpnConnectionStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
