// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipModelAdapter extends TypeAdapter<TipModel> {
  @override
  final int typeId = 0;

  @override
  TipModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TipModel(
      id: fields[0] as String,
      titleEn: fields[1] as String,
      titleAr: fields[2] as String,
      contentEn: fields[3] as String,
      contentAr: fields[4] as String,
      imageUrl: fields[5] as String,
      category: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TipModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titleEn)
      ..writeByte(2)
      ..write(obj.titleAr)
      ..writeByte(3)
      ..write(obj.contentEn)
      ..writeByte(4)
      ..write(obj.contentAr)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
