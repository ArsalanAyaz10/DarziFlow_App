import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:dariziflow_app/features/Messages/repositories/chat_repository.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:developer' as dev;

class ChatListController extends GetxController {
  final ChatRepository repository;
  final SocketService socketService;

  ChatListController({
    required this.repository,
    required this.socketService,
  });

  final RxList<ChatRoomModel> rooms = <ChatRoomModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentUserId = ''.obs;

  StreamSubscription<MessageModel>? _messageSubscription;

  // Search functionality
  final RxBool isSearching = false.obs;
  final RxList<AuthModel> searchResults = <AuthModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    fetchRooms();
    _subscribeToIncomingMessages();

    // Listen to text changes for debouncing
    searchController.addListener(() {
      final query = searchController.text;
      searchQuery.value = query;

      if (query.trim().isEmpty) {
        isSearching.value = false;
        searchResults.clear();
        return;
      }

      isSearching.value = true;
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        searchUsers(query);
      });
    });
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchRooms() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final fetched = await repository.fetchRooms();
      rooms.assignAll(fetched);
    } catch (e) {
      dev.log('[ChatListController] fetchRooms error: $e');
      errorMessage.value = 'Failed to load conversations.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      final results = await repository.searchGlobalUsers(query);
      searchResults.assignAll(results);
    } catch (e) {
      dev.log('[ChatListController] searchUsers error: $e');
      searchResults.clear();
    }
  }

  Future<void> startNewChat(String targetUserId) async {
    try {
      final room = await repository.findOrCreateDirectRoom(targetUserId);
      
      // Navigate to chat room
      Get.toNamed(Routes.chatRoom, arguments: room);
      
      // Optionally clear search
      searchController.clear();
      
      // Refresh the rooms list in the background
      fetchRooms();
    } catch (e) {
      dev.log('[ChatListController] startNewChat error: $e');
      Get.snackbar('Error', 'Failed to start chat. Please try again.');
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await AppStorage.getAuthUser();
    currentUserId.value = user?.id ?? '';
  }

  void _subscribeToIncomingMessages() {
    _messageSubscription = socketService.messageStream.listen((message) {
      final index = rooms.indexWhere((r) => r.id == message.chatRoomId);
      if (index != -1) {
        final updatedRoom = ChatRoomModel(
          id: rooms[index].id,
          name: rooms[index].name,
          type: rooms[index].type,
          orderId: rooms[index].orderId,
          participants: rooms[index].participants,
          lastMessage: message,
          createdAt: rooms[index].createdAt,
          updatedAt: message.createdAt,
        );
        rooms.removeAt(index);
        rooms.insert(0, updatedRoom);
      } else {
        // Fallback to fetchRooms to get the new room
        fetchRooms();
      }
    });
  }
}
