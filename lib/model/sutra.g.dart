// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sutra.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SutraAdapter extends TypeAdapter<Sutra> {
  @override
  final int typeId = 0;

  @override
  Sutra read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sutra(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      category: fields[3] as String,
      audio: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sutra obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.audio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SutraAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
