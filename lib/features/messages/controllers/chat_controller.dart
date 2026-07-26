import 'dart:async';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/chat_room_model.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/data/services/offline_queue_service.dart';
import 'package:dariziflow_app/data/models/pending_message.dart';
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

    // Process offline queue when socket reconnects
    ever(socketService.isConnected, (connected) {
      if (connected) {
        socketService.joinRoom(room.id);
        _processOfflineQueue();
        _syncMissedMessages();
      }
    });

    // Also process immediately if socket is already connected
    if (socketService.isConnected.value) {
      _processOfflineQueue();
    }

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
          // Remove corresponding pending message if it exists
          messages.removeWhere((m) => m.isPending && m.text == newMessage.text);
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

  Future<void> _processOfflineQueue() async {
    final allPending = OfflineQueueService.getAllPending();
    // Only process messages for the current room
    final roomPending = allPending.where((msg) => msg.chatRoomId == room.id).toList();
    if (roomPending.isEmpty) return;
    
    dev.log('[ChatController] Processing ${roomPending.length} offline messages for room ${room.id}...');
    for (var pendingMsg in roomPending) {
      final payload = {
        'chatRoomId': pendingMsg.chatRoomId,
        'senderId': pendingMsg.senderId,
        'text': pendingMsg.text,
        'media': [],
        'replyTo': pendingMsg.replyToId,
        'mentions': [],
      };
      
      socketService.emitSendMessage(payload);
      await OfflineQueueService.dequeue(pendingMsg.id);
      dev.log('[ChatController] Sent and dequeued offline message: ${pendingMsg.id}');
    }
    // Note: pending messages in the UI will be replaced when the server 
    // echoes back receive_message (handled in _setupSocketListeners via 
    // the isPending text-match removal logic)
  }

  void _syncMissedMessages() {
    if (messages.isNotEmpty) {
      // Get the last real (non-pending) message ID to sync from
      final lastRealMsg = messages.lastWhere((m) => !m.isPending, orElse: () => messages.last);
      if (!lastRealMsg.isPending) {
        dev.log('[ChatController] Syncing missed messages since ${lastRealMsg.id}');
        socketService.socket?.emit('sync_messages', {
          'roomId': room.id,
          'lastMessageId': lastRealMsg.id,
        });
      }
    }
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

      // Inject any pending messages from the offline queue back into the UI
      try {
        final pending = OfflineQueueService.getAllPending()
            .where((msg) => msg.chatRoomId == room.id);
        
        for (var pendingMsg in pending) {
          final optimisticMessage = MessageModel(
            id: pendingMsg.id,
            chatRoomId: pendingMsg.chatRoomId,
            sender: UserPreviewModel(
              id: pendingMsg.senderId,
              name: 'Me',
              role: 'CLIENT',
            ),
            text: pendingMsg.text,
            media: pendingMsg.mediaPath != null ? [MediaItemModel(url: pendingMsg.mediaPath!, type: pendingMsg.mediaType ?? 'image')] : [],
            mentions: [],
            createdAt: pendingMsg.createdAt,
            isPending: true,
          );
          messages.add(optimisticMessage);
        }
      } catch (e) {
        dev.log('[ChatController] Error loading pending messages: $e');
      }

      // Scroll to bottom after first load
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      dev.log('[ChatController] fetchInitialMessages error: $e');
      errorMessage.value = 'Failed to load messages.';
      
      // If we failed to load from network, STILL try to show pending messages
      try {
        final pending = OfflineQueueService.getAllPending()
            .where((msg) => msg.chatRoomId == room.id);
        
        for (var pendingMsg in pending) {
          final optimisticMessage = MessageModel(
            id: pendingMsg.id,
            chatRoomId: pendingMsg.chatRoomId,
            sender: UserPreviewModel(
              id: pendingMsg.senderId,
              name: 'Me',
              role: 'CLIENT',
            ),
            text: pendingMsg.text,
            media: pendingMsg.mediaPath != null ? [MediaItemModel(url: pendingMsg.mediaPath!, type: pendingMsg.mediaType ?? 'image')] : [],
            mentions: [],
            createdAt: pendingMsg.createdAt,
            isPending: true,
          );
          messages.add(optimisticMessage);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } catch (_) {}
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
        
        String cloudinaryResourceType = 'auto';
        if (pendingMediaType.value == 'document') {
          cloudinaryResourceType = 'raw';
        } else if (isAudio) {
          cloudinaryResourceType = 'video';
        }

        dev.log('[Voice] Signature received. Uploading to Cloudinary as $cloudinaryResourceType...');
        final uploadResult = await uploadService.uploadToCloudinary(
          file: pendingMediaFile.value!,
          cloudName: signatureData['cloudName'],
          apiKey: signatureData['apiKey'],
          timestamp: signatureData['timestamp'].toString(),
          signature: signatureData['signature'],
          folder: signatureData['folder'],
          resourceType: cloudinaryResourceType,
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
    final senderId = user?.id ?? currentUserId.value;
    final textToSend = trimmedText.isEmpty && mediaPayload.isNotEmpty ? "📎 Media" : trimmedText;

    final payload = {
      'chatRoomId': room.id,
      'senderId': senderId,
      'text': textToSend,
      'media': mediaPayload.isEmpty ? [] : mediaPayload,
      'replyTo': replyToMessage.value?.id,
      'mentions': [],
    };

    final isSocketConnected = socketService.socket?.connected ?? false;

    if (isSocketConnected) {
      dev.log('[Voice] Emitting socket message with payload: $payload');
      socketService.emitSendMessage(payload);
    } else {
      dev.log('[Voice] Socket disconnected, queueing message offline');
      final localId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save to Hive
      final pendingMsg = PendingMessage(
        id: localId,
        chatRoomId: room.id,
        senderId: senderId,
        text: textToSend,
        mediaPath: pendingMediaFile.value?.path,
        mediaType: pendingMediaType.value,
        replyToId: replyToMessage.value?.id,
        createdAt: DateTime.now(),
      );
      await OfflineQueueService.enqueue(pendingMsg);

      // Optimistic UI
      final optimisticMessage = MessageModel(
        id: localId,
        chatRoomId: room.id,
        sender: UserPreviewModel(
          id: senderId,
          name: user?.name ?? 'Me',
          role: user?.role ?? 'CLIENT',
        ),
        text: textToSend,
        media: mediaPayload.map((m) => MediaItemModel(url: m['url'] ?? '', type: m['type'] ?? '')).toList(),
        mentions: [],
        createdAt: DateTime.now(),
        isPending: true,
      );
      messages.add(optimisticMessage);
      _scrollToBottomIfNearBottom();
    }

    // Optimistic clear
    clearReply();
    clearPendingMedia();
  }

  Future<void> resendMessage(MessageModel message) async {
    if (!message.isPending) return;

    final isSocketConnected = socketService.socket?.connected ?? false;
    if (!isSocketConnected) {
      // Force a full reconnect (reinitializes the socket if disposed)
      dev.log('[ChatController] Socket not connected, forcing reconnect...');
      await socketService.connect();
      // The ever() listener on isConnected will auto-flush the queue
      // once the connection succeeds, so just return here
      return;
    }

    dev.log('[Voice] Resending pending message: ${message.id}');
    
    final payload = {
      'chatRoomId': message.chatRoomId,
      'senderId': message.sender.id,
      'text': message.text,
      'media': message.media.map((m) => {'url': m.url, 'type': m.type}).toList(),
      'replyTo': message.replyTo?.id,
      'mentions': [],
    };

    socketService.emitSendMessage(payload);
    
    // Dequeue from Hive so _processOfflineQueue won't re-send
    await OfflineQueueService.dequeue(message.id);
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
