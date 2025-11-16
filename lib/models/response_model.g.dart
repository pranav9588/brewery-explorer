// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreweryAdapter extends TypeAdapter<Brewery> {
  @override
  final int typeId = 1;

  @override
  Brewery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Brewery(
      id: fields[0] as String?,
      name: fields[1] as String?,
      breweryType: fields[2] as String?,
      address1: fields[3] as String?,
      address2: fields[4] as String?,
      address3: fields[5] as String?,
      city: fields[6] as String?,
      stateProvince: fields[7] as String?,
      postalCode: fields[8] as String?,
      country: fields[9] as String?,
      longitude: fields[10] as double?,
      latitude: fields[11] as double?,
      phone: fields[12] as String?,
      websiteUrl: fields[13] as String?,
      state: fields[14] as String?,
      street: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Brewery obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.breweryType)
      ..writeByte(3)
      ..write(obj.address1)
      ..writeByte(4)
      ..write(obj.address2)
      ..writeByte(5)
      ..write(obj.address3)
      ..writeByte(6)
      ..write(obj.city)
      ..writeByte(7)
      ..write(obj.stateProvince)
      ..writeByte(8)
      ..write(obj.postalCode)
      ..writeByte(9)
      ..write(obj.country)
      ..writeByte(10)
      ..write(obj.longitude)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.phone)
      ..writeByte(13)
      ..write(obj.websiteUrl)
      ..writeByte(14)
      ..write(obj.state)
      ..writeByte(15)
      ..write(obj.street);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreweryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
