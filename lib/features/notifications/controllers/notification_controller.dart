import 'package:dariziflow_app/data/models/notification_model.dart';
import 'package:dariziflow_app/features/notifications/repositories/notification_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationRepository repository;

  NotificationController({required this.repository});

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final rawData = await repository.fetchNotifications();
      
      notifications.value = rawData
          .map((e) {
            try {
              return NotificationModel.fromJson(e as Map<String, dynamic>);
            } catch (err) {
              if (kDebugMode) print("Error parsing notification: $err");
              return null;
            }
          })
          .whereType<NotificationModel>()
          .toList();

      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      if (kDebugMode) print("Error in fetchNotifications controller: $e");
      Get.snackbar("Error", "Failed to load notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final success = await repository.markAsRead(id);
    if (success) {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh(); 
        unreadCount.value = notifications.where((n) => !n.isRead).length;
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await repository.markAllAsRead();
    if (success) {
      for (var n in notifications) {
        n.isRead = true;
      }
      notifications.refresh();
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    }
  }
}
