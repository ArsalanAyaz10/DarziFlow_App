import 'package:dariziflow_app/core/network/api_client.dart';

class ChatService {
  final ApiClient apiClient;

  ChatService({required this.apiClient});

  Future<dynamic> fetchRooms() async {
    return apiClient.get('/chat/rooms');
  }

  Future<dynamic> fetchMessages(
    String roomId, {
    int page = 1,
    int limit = 30,
  }) async {
    return apiClient.get(
      '/chat/rooms/$roomId/messages',
      query: {'page': page, 'limit': limit},
    );
  }

  Future<dynamic> findOrCreateDirectRoom(String targetUserId) async {
    return apiClient.post(
      '/chat/rooms/direct',
      data: {'targetUserId': targetUserId},
    );
  }

  Future<dynamic> searchGlobalUsers(String query) async {
    return apiClient.get('/chat/users/search', query: {'query': query});
  }
}
