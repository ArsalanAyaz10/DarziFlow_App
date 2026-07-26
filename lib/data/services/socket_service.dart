import 'dart:async';
import 'dart:developer' as dev;

import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/message_model.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService extends GetxService {
  final ApiClient apiClient;

  SocketService({required this.apiClient});

  io.Socket? _socket;
  io.Socket? get socket => _socket;

  /// The roomId currently open on screen. Set by ChatController.
  final RxnString activeRoomId = RxnString(null);

  /// Connection state observable for other controllers to react to.
  final RxBool isConnected = false.obs;

  /// Stream that ChatController subscribes to for incoming messages.
  final _messageController = StreamController<MessageModel>.broadcast();
  Stream<MessageModel> get messageStream => _messageController.stream;

  /// Callback registered by ChatController for typing events.
  void Function(String userName)? _onTypingCallback;

  bool _isConnecting = false;

  // ─── Connect ──────────────────────────────────────────────────────────────

  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    final token = await AppStorage.getAccessToken();
    if (token == null) {
      dev.log('[SocketService] No access token — skipping connect.');
      _isConnecting = false;
      return;
    }

    _initSocket(token);
  }

  void _initSocket(String token) {
    // Dispose any existing socket cleanly first
    _socket?.dispose();

    // Derive the base URL from the ApiService (syncs with Ngrok fallback)
    String baseUrl = 'http://localhost:5000';
    try {
      final apiService = Get.find<ApiService>();
      baseUrl = apiService.currentBaseUrl;
    } catch (_) {}

    // Sanitize URL to prevent invalid port appending and strip the REST /api path
    String sanitizedUrl = baseUrl.replaceAll(':0', '');
    if (sanitizedUrl.endsWith('/')) {
      sanitizedUrl = sanitizedUrl.substring(0, sanitizedUrl.length - 1);
    }
    if (sanitizedUrl.endsWith('/api')) {
      sanitizedUrl = sanitizedUrl.substring(0, sanitizedUrl.length - 4);
    }
    
    // Explicitly add port to avoid socket_io_client bug appending :0
    try {
      final uri = Uri.parse(sanitizedUrl);
      if (!uri.hasPort) {
        sanitizedUrl = '${uri.scheme}://${uri.host}:${uri.scheme == 'https' ? 443 : 80}${uri.path}';
      }
    } catch (_) {}

    dev.log('🔗 [FLUTTER SOCKET] Initializing with sanitized URL: $sanitizedUrl');

    _socket = io.io(
      sanitizedUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(double.maxFinite.toInt())
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setAuth({'token': token})
          .build(),
    );

    // FORCE debug logs on the socket instance
    _socket!.onConnect((_) {
      dev.log('✅ [FLUTTER SOCKET] Successfully connected to server! ID: ${_socket!.id}');
      dev.log('[SocketService] ✅ Connected: ${_socket!.id}');
      _isConnecting = false;
      isConnected.value = true;
      
      // Re-join the active room upon connection/reconnection
      if (activeRoomId.value != null) {
        joinRoom(activeRoomId.value!);
      }
    });

    _socket!.onConnectError((err) {
      dev.log('❌ [FLUTTER SOCKET ERROR] Connection Failed: $err');
    });

    _socket!.onError((err) {
      dev.log('❌ [FLUTTER SOCKET ERROR] General Error: $err');
      dev.log('[SocketService] Error: $err');
    });

    _socket!.onDisconnect((_) {
      dev.log('🛑 [FLUTTER SOCKET] Disconnected from server.');
      dev.log('[SocketService] Disconnected.');
      isConnected.value = false;
    });

    _socket!.on('receive_message', (data) {
      _handleIncomingMessage(data);
    });

    _socket!.on('missed_messages', (data) {
      _handleMissedMessages(data);
    });

    _socket!.on('user_typing', (data) {
      final userName = data['userName']?.toString() ?? '';
      if (userName.isNotEmpty) {
        _onTypingCallback?.call(userName);
      }
    });

    _socket!.on('message_error', (data) {
      dev.log('[SocketService] message_error: $data');
    });

    _socket!.on('connect_error', (error) async {
      dev.log('❌ [FLUTTER SOCKET ERROR] Connection Failed (connect_error event): $error');
      dev.log('[SocketService] connect_error: $error');
      _isConnecting = false;
      final errStr = error.toString().toLowerCase();
      if (errStr.contains('token') ||
          errStr.contains('expired') ||
          errStr.contains('unauthorized') ||
          errStr.contains('jwt')) {
        await _refreshTokenAndReconnect();
      } else {
        // Assume network error or 403, trigger fallback
        try {
          final apiService = Get.find<ApiService>();
          // Only trigger if we aren't ALREADY on the fallback
          if (apiService.currentBaseUrl == apiService.primaryUrl) {
            apiService.triggerFallback();
            _initSocket(token);
          }
        } catch (_) {}
      }
    });

    _socket!.connect();
  }

  // ─── Token Refresh & Reconnect ────────────────────────────────────────────

  Future<void> _refreshTokenAndReconnect() async {
    try {
      dev.log('[SocketService] Refreshing token via REST...');
      // A GET to any protected endpoint triggers AuthInterceptor to silently
      // update the access token from the x-access-token response header.
      await apiClient.get('auth/me');
    } catch (e) {
      dev.log('[SocketService] Token refresh failed: $e');
      return;
    }

    final freshToken = await AppStorage.getAccessToken();
    if (freshToken != null) {
      dev.log('[SocketService] Token refreshed — reconnecting socket.');
      _initSocket(freshToken);
    }
  }

  // ─── Room Events ─────────────────────────────────────────────────────────

  void joinRoom(String roomId) {
    _socket?.emit('join_room', roomId);
    dev.log('[SocketService] Emitted join_room: $roomId');
  }

  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', roomId);
    dev.log('[SocketService] Emitted leave_room: $roomId');
  }

  void emitSendMessage(Map<String, dynamic> payload) {
    _socket?.emit('send_message', payload);
    dev.log('[SocketService] Emitted send_message');
  }

  void emitTyping(String chatRoomId, String userName) {
    _socket?.emit('typing', {'chatRoomId': chatRoomId, 'userName': userName});
  }

  /// Register a callback for incoming typing events. Called by ChatController.
  void listenToTyping(void Function(String userName) callback) {
    _onTypingCallback = callback;
  }

  /// Unregister the typing callback. Called by ChatController.onClose.
  void stopListeningToTyping() {
    _onTypingCallback = null;
  }

  // ─── Incoming Messages ───────────────────────────────────────────────────

  void _handleIncomingMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = Map<String, dynamic>.from(data);
      final message = MessageModel.fromJson(json);

      dev.log(
          '[SocketService] receive_message in room: ${message.chatRoomId}');

      // Always push to stream so ChatController can pick it up
      _messageController.add(message);

      // If the user is NOT viewing this room, trigger a local notification
      if (activeRoomId.value != message.chatRoomId) {
        _triggerLocalNotification(message);
      }
    } catch (e) {
      dev.log('[SocketService] Error parsing receive_message: $e');
    }
  }

  void _handleMissedMessages(dynamic data) {
    try {
      final List<dynamic> list = List<dynamic>.from(data);
      dev.log('[SocketService] missed_messages received: ${list.length} messages');
      for (var item in list) {
        final json = Map<String, dynamic>.from(item);
        final message = MessageModel.fromJson(json);
        _messageController.add(message);
      }
    } catch (e) {
      dev.log('[SocketService] Error parsing missed_messages: $e');
    }
  }

  void _triggerLocalNotification(MessageModel message) {
    // Uses the existing NotificationController / flutter_local_notifications
    // The notification service is already wired globally — just log for now
    // and the NotificationController can subscribe to messageStream independently.
    dev.log(
        '[SocketService] 🔔 Background notification: ${message.sender.name}: ${message.text}');
  }

  // ─── Disconnect ───────────────────────────────────────────────────────────

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    dev.log('[SocketService] Socket disposed.');
  }

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    super.onClose();
  }
}
