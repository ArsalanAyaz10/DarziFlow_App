import 'package:hive/hive.dart';

part 'pending_message.g.dart';

@HiveType(typeId: 0)
class PendingMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String chatRoomId;

  @HiveField(2)
  final String senderId;

  @HiveField(3)
  final String text;

  @HiveField(4)
  final String? mediaPath;

  @HiveField(5)
  final String? mediaType; // 'image' | 'audio' | 'document'

  @HiveField(6)
  final String? replyToId;
  
  @HiveField(7)
  final DateTime createdAt;

  PendingMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    this.mediaPath,
    this.mediaType,
    this.replyToId,
    required this.createdAt,
  });
}
