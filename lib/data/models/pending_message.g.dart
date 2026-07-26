// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingMessageAdapter extends TypeAdapter<PendingMessage> {
  @override
  final int typeId = 0;

  @override
  PendingMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingMessage(
      id: fields[0] as String,
      chatRoomId: fields[1] as String,
      senderId: fields[2] as String,
      text: fields[3] as String,
      mediaPath: fields[4] as String?,
      mediaType: fields[5] as String?,
      replyToId: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingMessage obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatRoomId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.mediaPath)
      ..writeByte(5)
      ..write(obj.mediaType)
      ..writeByte(6)
      ..write(obj.replyToId)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
