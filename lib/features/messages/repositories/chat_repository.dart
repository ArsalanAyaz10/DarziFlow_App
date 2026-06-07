import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:dariziflow_app/features/Messages/service/chat_service.dart';
import 'dart:developer' as dev;

class ChatRepository {
  final ChatService chatService;

  ChatRepository({required this.chatService});

  /// Fetches all chat rooms the current user belongs to.
  Future<List<ChatRoomModel>> fetchRooms() async {
    try {
      final response = await chatService.fetchRooms();
      final data = response.data;
      final List<dynamic> rawRooms = data['rooms'] ?? [];
      return rawRooms
          .map((r) => ChatRoomModel.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    } catch (e) {
      dev.log('[ChatRepository] fetchRooms error: $e');
      rethrow;
    }
  }

  /// Fetches paginated message history for a room.
  Future<List<MessageModel>> fetchMessages(
    String roomId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await chatService.fetchMessages(
        roomId,
        page: page,
        limit: limit,
      );
      final data = response.data;
      final List<dynamic> rawMessages = data['messages'] ?? [];
      return rawMessages
          .map((m) => MessageModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      dev.log('[ChatRepository] fetchMessages error: $e');
      rethrow;
    }
  }

  /// Finds or creates a direct 1-on-1 chat room with another user.
  Future<ChatRoomModel> findOrCreateDirectRoom(String targetUserId) async {
    try {
      final response = await chatService.findOrCreateDirectRoom(targetUserId);
      final data = response.data;
      return ChatRoomModel.fromJson(Map<String, dynamic>.from(data['room']));
    } catch (e) {
      dev.log('[ChatRepository] findOrCreateDirectRoom error: $e');
      rethrow;
    }
  }

  /// Searches global users for new chats
  Future<List<AuthModel>> searchGlobalUsers(String query) async {
    try {
      final response = await chatService.searchGlobalUsers(query);
      final data = response.data;
      final List<dynamic> rawUsers = data['users'] ?? [];
      return rawUsers
          .map((u) => AuthModel.fromJson(Map<String, dynamic>.from(u)))
          .toList();
    } catch (e) {
      dev.log('[ChatRepository] searchGlobalUsers error: $e');
      rethrow;
    }
  }
}
