import 'package:dariziflow_app/data/models/message_model.dart';

class ChatRoomModel {
  final String id;
  final String? name;
  final String type; // 'direct' | 'group'
  final String? orderId;
  final List<UserPreviewModel> participants;
  final MessageModel? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatRoomModel({
    required this.id,
    this.name,
    required this.type,
    this.orderId,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Participants can be List<UserPreview> OR List<String> (IDs only)
    final rawParticipants = json['participants'] as List<dynamic>? ?? [];
    final participants = rawParticipants
        .whereType<Map<dynamic, dynamic>>()
        .map((p) => UserPreviewModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    // lastMessage can be null, a MessageModel map, or a string ID
    MessageModel? lastMessage;
    if (json['lastMessage'] != null && json['lastMessage'] is Map) {
      lastMessage = MessageModel.fromJson(
          Map<String, dynamic>.from(json['lastMessage']));
    }

    return ChatRoomModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString(),
      type: json['type']?.toString() ?? 'direct',
      orderId: json['orderId']?.toString(),
      participants: participants,
      lastMessage: lastMessage,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        if (name != null) 'name': name,
        'type': type,
        if (orderId != null) 'orderId': orderId,
        'participants': participants.map((p) => p.toJson()).toList(),
        if (lastMessage != null) 'lastMessage': lastMessage!.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Returns the other participant's name for 1-on-1 direct chats.
  String displayName(String currentUserId) {
    if (name != null && name!.isNotEmpty) return name!;
    final other = participants.where((p) => p.id != currentUserId).toList();
    if (other.isNotEmpty) return other.first.name;
    return 'Chat';
  }

  /// Returns the other participant for 1-on-1 direct chats.
  UserPreviewModel? otherParticipant(String currentUserId) {
    final other = participants.where((p) => p.id != currentUserId).toList();
    return other.isNotEmpty ? other.first : null;
  }
}
