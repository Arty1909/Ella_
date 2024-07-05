// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranges.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RangeAdapter extends TypeAdapter<Range> {
  @override
  final int typeId = 1;

  @override
  Range read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Range(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Range obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
