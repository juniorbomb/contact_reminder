// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackContactModelAdapter extends TypeAdapter<TrackContactModel> {
  @override
  final int typeId = 0;

  @override
  TrackContactModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackContactModel(
      name: fields[0] as String?,
      number: fields[1] as String?,
      createdDate: fields[2] as DateTime?,
      identifier: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackContactModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.identifier);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackContactModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
