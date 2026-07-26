import 'dart:convert';

class UserPreviewModel {
  final String id;
  final String name;
  final String role;
  final String? avatar;

  const UserPreviewModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
  });

  factory UserPreviewModel.fromJson(Map<String, dynamic> json) {
    String? parsedAvatar;
    if (json['avatar'] != null) {
      if (json['avatar'] is Map) {
        parsedAvatar = json['avatar']['url']?.toString();
      } else if (json['avatar'] is String) {
        try {
          // In case the backend sends stringified JSON
          final decoded = jsonDecode(json['avatar']);
          if (decoded is Map) {
            parsedAvatar = decoded['url']?.toString();
          } else {
            parsedAvatar = json['avatar'];
          }
        } catch (e) {
          // If it's just a normal string URL
          parsedAvatar = json['avatar'];
        }
      }
    }

    return UserPreviewModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      avatar: parsedAvatar,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'role': role,
        if (avatar != null) 'avatar': avatar,
      };

  String get formattedRole {
    switch (role.toUpperCase()) {
      case 'CLIENT':
        return 'Client';
      case 'DEPARTMENT_HEAD':
        return 'Dept Head';
      case 'QC_MEMBER':
        return 'QC Member';
      default:
        return role;
    }
  }
}

class MediaItemModel {
  final String url;
  final String type; // 'image' | 'video' | 'document'

  const MediaItemModel({required this.url, required this.type});

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'image',
    );
  }

  Map<String, dynamic> toJson() => {'url': url, 'type': type};
}

class ReplyToModel {
  final String id;
  final String text;
  final List<MediaItemModel> media;
  final String senderName;

  const ReplyToModel({
    required this.id,
    required this.text,
    required this.media,
    required this.senderName,
  });

  factory ReplyToModel.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List<dynamic>? ?? [])
        .map((m) => MediaItemModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    return ReplyToModel(
      id: json['_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      media: mediaList,
      senderName: json['sender']?['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'text': text,
        'media': media.map((m) => m.toJson()).toList(),
        'sender': {'name': senderName},
      };
}

class MessageModel {
  final String id;
  final String chatRoomId;
  final UserPreviewModel sender;
  final String text;
  final List<MediaItemModel> media;
  final ReplyToModel? replyTo;
  final List<Map<String, dynamic>> mentions;
  final DateTime createdAt;
  final bool isPending;

  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.sender,
    required this.text,
    required this.media,
    this.replyTo,
    required this.mentions,
    required this.createdAt,
    this.isPending = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final mediaList = (json['media'] as List<dynamic>? ?? [])
        .map((m) => MediaItemModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();

    final mentionsList = (json['mentions'] as List<dynamic>? ?? [])
        .map((m) => Map<String, dynamic>.from(m))
        .toList();

    ReplyToModel? replyTo;
    if (json['replyTo'] != null && json['replyTo'] is Map) {
      replyTo = ReplyToModel.fromJson(
          Map<String, dynamic>.from(json['replyTo']));
    }

    return MessageModel(
      id: json['_id']?.toString() ?? '',
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      sender: UserPreviewModel.fromJson(
          Map<String, dynamic>.from(json['sender'] ?? {})),
      text: json['text']?.toString() ?? '',
      media: mediaList,
      replyTo: replyTo,
      mentions: mentionsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isPending: json['isPending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'chatRoomId': chatRoomId,
        'sender': sender.toJson(),
        'text': text,
        'media': media.map((m) => m.toJson()).toList(),
        if (replyTo != null) 'replyTo': replyTo!.toJson(),
        'mentions': mentions,
        'createdAt': createdAt.toIso8601String(),
        'isPending': isPending,
      };
}
