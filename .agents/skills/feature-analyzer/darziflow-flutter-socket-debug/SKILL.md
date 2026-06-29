---
name: darziflow-flutter-socket-debug
description: Workflow to forcefully debug and resolve silent WebSocket connection failures in the Flutter SocketService.
---

# Forensic Trace: Flutter Socket Connection Integrity

## 📌 Context
The Node.js backend has aggressive socket logging, but no events (not even a connection event) are registering on the server. The Flutter app is failing to establish the WebSocket connection silently. We need to add aggressive lifecycle listeners to `SocketService.dart` to expose why it's failing.

## 🛠️ Step 1: Aggressive Flutter Socket Logging (`SocketService.dart`)

Agent, the `socket_io_client` is likely failing during the handshake or due to a network URI issue. We must expose the internal logs.

1. Open `SocketService.dart`.
2. Inside the `connect()` method, immediately after initializing `io.io(...)`, attach these explicit lifecycle listeners BEFORE doing anything else:

```dart
// FORCE debug logs on the socket instance
socket.onConnect((_) {
  print("✅ [FLUTTER SOCKET] Successfully connected to server! ID: ${socket.id}");
});

socket.onConnectError((err) {
  print("❌ [FLUTTER SOCKET ERROR] Connection Failed: $err");
});

socket.onError((err) {
  print("❌ [FLUTTER SOCKET ERROR] General Error: $err");
});

socket.onDisconnect((_) {
  print("🛑 [FLUTTER SOCKET] Disconnected from server.");
});