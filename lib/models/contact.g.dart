// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactModelAdapter extends TypeAdapter<ContactModel> {
  @override
  final int typeId = 1;

  @override
  ContactModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactModel(
      displayName: fields[1] as String?,
      givenName: fields[2] as String?,
      middleName: fields[3] as String?,
      prefix: fields[4] as String?,
      suffix: fields[5] as String?,
      familyName: fields[6] as String?,
      company: fields[7] as String?,
      jobTitle: fields[8] as String?,
      emails: (fields[11] as List?)?.cast<Item>(),
      phones: (fields[12] as List?)?.cast<Item>(),
      avatar: fields[13] as Uint8List?,
      birthday: fields[14] as DateTime?,
      androidAccountTypeRaw: fields[9] as String?,
      androidAccountName: fields[10] as String?,
    )..identifier = fields[0] as String?;
  }

  @override
  void write(BinaryWriter writer, ContactModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.identifier)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.givenName)
      ..writeByte(3)
      ..write(obj.middleName)
      ..writeByte(4)
      ..write(obj.prefix)
      ..writeByte(5)
      ..write(obj.suffix)
      ..writeByte(6)
      ..write(obj.familyName)
      ..writeByte(7)
      ..write(obj.company)
      ..writeByte(8)
      ..write(obj.jobTitle)
      ..writeByte(9)
      ..write(obj.androidAccountTypeRaw)
      ..writeByte(10)
      ..write(obj.androidAccountName)
      ..writeByte(11)
      ..write(obj.emails)
      ..writeByte(12)
      ..write(obj.phones)
      ..writeByte(13)
      ..write(obj.avatar)
      ..writeByte(14)
      ..write(obj.birthday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
