// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'untitled204.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CarHiveObjectAdapter extends TypeAdapter<CarHiveObject> {
  @override
  final int typeId = 0;

  @override
  CarHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CarHiveObject(
      name: fields[0] as String,
      power: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CarHiveObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.power);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CarHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarDTO _$CarDTOFromJson(Map<String, dynamic> json) => CarDTO(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      power: (json['power'] as num).toDouble(),
    );

Map<String, dynamic> _$CarDTOToJson(CarDTO instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'power': instance.power,
    };
