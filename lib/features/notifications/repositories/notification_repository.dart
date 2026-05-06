import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<List<dynamic>> fetchNotifications() async {
    try {
      final response = await apiClient.get('/notifications');
      final data = response.data;

      if (data is List) return data;
      if (data is Map) return data['notifications'] ?? data['data'] ?? [];
      return [];
    } catch (e) {
      if (kDebugMode) {
        dev.log("API Error fetching notifications: $e");
      }
      rethrow; // Let the Controller handle the UI error state
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      final response = await apiClient.patch('/notifications/$id/read');
      final data = response.data;
      return data['success'] ?? true;
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error marking notification as read: $e");
      }
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final response = await apiClient.patch('/notifications/read-all');
      final data = response.data;
      return data['success'] ?? true;
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error marking all notifications as read: $e");
      }
      return false;
    }
  }
}
