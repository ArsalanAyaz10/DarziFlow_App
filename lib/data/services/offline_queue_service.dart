import 'package:dariziflow_app/data/models/pending_message.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as dev;

class OfflineQueueService {
  static const String _boxName = 'offline_messages';
  static Box<PendingMessage>? _box;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(PendingMessageAdapter());
      _box = await Hive.openBox<PendingMessage>(_boxName);
      dev.log('[OfflineQueueService] Initialized Hive and opened box: $_boxName');
    } catch (e) {
      dev.log('[OfflineQueueService] Error initializing: $e');
    }
  }

  static Future<void> enqueue(PendingMessage message) async {
    if (_box == null) return;
    try {
      await _box!.put(message.id, message);
      dev.log('[OfflineQueueService] Enqueued message: ${message.id}');
    } catch (e) {
      dev.log('[OfflineQueueService] Error enqueueing: $e');
    }
  }

  static Future<void> dequeue(String id) async {
    if (_box == null) return;
    try {
      await _box!.delete(id);
      dev.log('[OfflineQueueService] Dequeued message: $id');
    } catch (e) {
      dev.log('[OfflineQueueService] Error dequeueing: $e');
    }
  }

  static List<PendingMessage> getAllPending() {
    if (_box == null) return [];
    final messages = _box!.values.toList();
    // Sort by created time to maintain order
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }
}
