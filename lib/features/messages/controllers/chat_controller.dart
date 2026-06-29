import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/Messages/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final ChatRepository repository;
  final SocketService socketService;
  final UploadService uploadService;

  ChatController({
    required this.repository,
    required this.socketService,
    required this.uploadService,
  });

  // ─── State ────────────────────────────────────────────────────────────────

  late final ChatRoomModel room;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreMessages = true.obs;
  final RxBool isSendingMedia = false.obs;
  final RxString errorMessage = ''.obs;

  // Reply-to
  final Rxn<MessageModel> replyToMessage = Rxn<MessageModel>(null);

  // Typing indicator
  final RxString typingUser = ''.obs;
  Timer? _typingDismissTimer;
  Timer? _typingDebounceTimer;

  // Attachment
  final Rxn<File> pendingMediaFile = Rxn<File>(null);
  final RxString pendingMediaType = ''.obs; // 'image' | 'document'

  // Pagination
  int _currentPage = 1;
  static const int _pageLimit = 30;

  // Scroll
  final ScrollController scrollController = ScrollController();
  final RxBool showScrollToBottom = false.obs;

  // Stream subscription
  StreamSubscription<MessageModel>? _messageSubscription;

  // Current user
  final RxString currentUserId = ''.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    room = Get.arguments as ChatRoomModel;

    _loadCurrentUser();
    _setupSocketListeners();
    _subscribeToSocketEvents();

    // Mark this room as active so SocketService won't fire notifications
    socketService.activeRoomId.value = room.id;
    socketService.joinRoom(room.id);

    _fetchInitialMessages();

    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    socketService.activeRoomId.value = null;
    socketService.leaveRoom(room.id);
    socketService.stopListeningToTyping();

    _messageSubscription?.cancel();
    _typingDismissTimer?.cancel();
    _typingDebounceTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Init helpers ─────────────────────────────────────────────────────────

  Future<void> _loadCurrentUser() async {
    final user = await AppStorage.getAuthUser();
    currentUserId.value = user?.id ?? '';
  }

  void _setupSocketListeners() {
    _messageSubscription = socketService.messageStream.listen((newMessage) {
      dev.log('📥 [FLUTTER CHAT] New message received from stream: ${newMessage.text}');
      if (newMessage.chatRoomId == room.id) {
        // Prevent duplicate messages
        if (!messages.any((m) => m.id == newMessage.id)) {
          messages.add(newMessage);
          _scrollToBottomIfNearBottom();
        }
      }
    });
  }

  void _subscribeToSocketEvents() {
    // Listen to typing events through the raw socket
    socketService.listenToTyping((userName) {
      typingUser.value = userName;
      _typingDismissTimer?.cancel();
      _typingDismissTimer = Timer(const Duration(seconds: 3), () {
        typingUser.value = '';
      });
    });
  }

  // ─── Pagination & Fetch ───────────────────────────────────────────────────

  Future<void> _fetchInitialMessages() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      _currentPage = 1;
      final fetched = await repository.fetchMessages(
        room.id,
        page: _currentPage,
        limit: _pageLimit,
      );
      messages.assignAll(fetched);
      hasMoreMessages.value = fetched.length >= _pageLimit;

      // Scroll to bottom after first load
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      dev.log('[ChatController] fetchInitialMessages error: $e');
      errorMessage.value = 'Failed to load messages.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreMessages() async {
    if (isLoadingMore.value || !hasMoreMessages.value) return;
    isLoadingMore.value = true;

    // Save scroll position before prepending
    final previousExtent = scrollController.position.maxScrollExtent;

    try {
      _currentPage++;
      final fetched = await repository.fetchMessages(
        room.id,
        page: _currentPage,
        limit: _pageLimit,
      );

      if (fetched.isEmpty) {
        hasMoreMessages.value = false;
      } else {
        messages.insertAll(0, fetched);
        hasMoreMessages.value = fetched.length >= _pageLimit;

        // Restore scroll so the user stays at the same position
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            final newExtent = scrollController.position.maxScrollExtent;
            scrollController.jumpTo(
              scrollController.offset + (newExtent - previousExtent),
            );
          }
        });
      }
    } catch (e) {
      dev.log('[ChatController] loadMoreMessages error: $e');
      _currentPage--; // Roll back on failure
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ─── Send Message ─────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    dev.log('[Voice] sendMessage called. isSendingMedia: ${isSendingMedia.value}');
    if (isSendingMedia.value) return;
    
    final trimmedText = text.trim();
    dev.log('[Voice] Text: "$trimmedText", PendingMedia: ${pendingMediaFile.value?.path}');
    if (trimmedText.isEmpty && pendingMediaFile.value == null) return;

    List<Map<String, dynamic>> mediaPayload = [];

    // Upload media first if present
    if (pendingMediaFile.value != null) {
      isSendingMedia.value = true;
      try {
        final isAudio = pendingMediaType.value == 'audio';
        dev.log('[Voice] Requesting upload signature for room ${room.id}...');
        final signatureData = await uploadService.getChatUploadSignature(
          chatRoomId: room.id,
        );
        dev.log('[Voice] Signature received. Uploading to Cloudinary as ${isAudio ? 'video' : 'auto'}...');
        final uploadResult = await uploadService.uploadToCloudinary(
          file: pendingMediaFile.value!,
          cloudName: signatureData['cloudName'],
          apiKey: signatureData['apiKey'],
          timestamp: signatureData['timestamp'].toString(),
          signature: signatureData['signature'],
          folder: signatureData['folder'],
          resourceType: isAudio ? 'video' : 'auto',
        );
        dev.log('[Voice] Cloudinary upload success: ${uploadResult['secure_url']}');
        final backendType = isAudio ? 'document' : pendingMediaType.value;
        final finalUrl = isAudio 
            ? '${uploadResult['secure_url']}?isVoice=true' 
            : uploadResult['secure_url'];
            
        mediaPayload = [
          {'url': finalUrl, 'type': backendType}
        ];
      } catch (e) {
        dev.log('[ChatController] Media upload failed: $e');
        Get.snackbar('Upload Failed', 'Could not upload media. Please try again.');
        isSendingMedia.value = false;
        return;
      } finally {
        isSendingMedia.value = false;
      }
    }

    final user = await AppStorage.getAuthUser();

    final payload = {
      'chatRoomId': room.id,
      'senderId': user?.id ?? currentUserId.value,
      'text': trimmedText,
      'media': mediaPayload.isEmpty ? [] : mediaPayload,
      'replyTo': replyToMessage.value?.id,
      'mentions': [],
    };
    dev.log('[Voice] Emitting socket message with payload: $payload');
    socketService.emitSendMessage(payload);

    // Optimistic clear
    clearReply();
    clearPendingMedia();
  }

  // ─── Typing ───────────────────────────────────────────────────────────────

  void onTextChanged(String value) {
    if (value.isEmpty) return;
    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final user = await AppStorage.getAuthUser();
      if (user != null) {
        socketService.emitTyping(room.id, user.name);
      }
    });
  }

  // ─── Reply ────────────────────────────────────────────────────────────────

  void setReplyTo(MessageModel message) {
    replyToMessage.value = message;
  }

  void clearReply() {
    replyToMessage.value = null;
  }

  // ─── Media ────────────────────────────────────────────────────────────────

  void setPendingMedia(File file, String type) {
    pendingMediaFile.value = file;
    pendingMediaType.value = type;
  }

  void clearPendingMedia() {
    pendingMediaFile.value = null;
    pendingMediaType.value = '';
  }

  // ─── Scroll ───────────────────────────────────────────────────────────────

  void _onScroll() {
    if (!scrollController.hasClients) return;

    // Trigger load-more when within 150px of the top
    if (scrollController.position.pixels <= 150) {
      loadMoreMessages();
    }

    // Show "scroll to bottom" button when far from bottom
    final distanceFromBottom = scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    showScrollToBottom.value = distanceFromBottom > 300;
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomIfNearBottom() {
    if (!scrollController.hasClients) return;
    final distanceFromBottom = scrollController.position.maxScrollExtent -
        scrollController.position.pixels;
    if (distanceFromBottom < 300) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void scrollToBottom() => _scrollToBottom();

  // ─── Helpers ──────────────────────────────────────────────────────────────

  bool isMyMessage(MessageModel message) {
    return message.sender.id == currentUserId.value;
  }
}
