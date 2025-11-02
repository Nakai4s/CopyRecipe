// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 0;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      id: fields[0] as String,
      title: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      channelTitle: fields[3] as String,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.channelTitle)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
