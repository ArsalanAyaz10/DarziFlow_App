import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/qc_history_model.dart';
import 'package:dariziflow_app/data/models/carousel_model.dart';
import 'package:dariziflow_app/features/Client/services/client_service.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ClientDashboardController extends GetxController {
  final ClientService _clientService = Get.find<ClientService>();

  final userName = "".obs;
  final userAvatar = "".obs;
  final isLoading = false.obs;

  // Stats
  final activeOrdersCount = 0.obs;
  final completedOrdersCount = 0.obs;
  final totalOrdersCount = 0.obs;
  final totalSpent = 0.0.obs;

  // Data lists
  final orders = <OrderModel>[].obs;
  final recentActivities = <QcHistoryModel>[].obs;
  final carouselItems = <CarouselModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchDashboardData();
  }

  Future<void> _loadUserData() async {
    final user = await AppStorage.getAuthUser();
    if (user != null) {
      userName.value = user.name;
      userAvatar.value = user.avatarUrl;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      
      // Fetch stats and orders
      final stats = await _clientService.getAllOrders();
      activeOrdersCount.value = stats['activeOrders'];
      completedOrdersCount.value = stats['completedOrders'];
      totalOrdersCount.value = stats['totalOrders'];
      orders.assignAll(stats['orders']);

      // Calculate total spent (just as an example logic)
      double spent = 0;
      for (var order in orders) {
        spent += order.amount;
      }
      totalSpent.value = spent;

      // Fetch recent history
      final activities = await _clientService.getRecentHistory();
      recentActivities.assignAll(activities);

      // Fetch Carousel Items
      final carousel = await _clientService.getCarouselItems();
      carouselItems.assignAll(carousel);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch dashboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha:0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // UI Mapping Helpers
  List<Map<String, dynamic>> get mappedRecentOrders {
    return orders.take(3).map((order) {
      // Find current milestone from operations
      String milestone = "Pending";
      if (order.operations.isNotEmpty) {
        final activeOp = order.operations.firstWhere(
          (op) => op.status == 'IN_PROGRESS',
          orElse: () => order.operations.first,
        );
        milestone = activeOp.name;
      }

      return {
        "id": order.displayOrderId,
        "name": order.orderName,
        "status": order.overallStatus,
        "image": "", // Will be handled by UI if empty
        "progress": order.progress.toInt(),
        "milestone": milestone,
        "originalModel": order, // Keep reference for navigation
      };
    }).toList();
  }

  List<Map<String, dynamic>> get mappedActivities {
    return recentActivities.take(3).map((activity) {
      String type = 'movement';
      if (activity.action == 'APPROVE' || activity.action == 'FINAL_APPROVE') {
        type = 'approval';
      } else if (activity.action == 'REJECT') {
        type = 'rejection';
      } else if (activity.action == 'SUBMIT') {
        type = 'submission';
      }

      return {
        "title": "${activity.checkpointName} ${activity.action}",
        "subtitle": "${activity.orderName}: ${activity.comment}",
        "timeAgo": _formatTimeAgo(activity.createdAt),
        "type": type,
        "orderId": activity.orderId,
      };
    }).toList();
  }

  List<Map<String, dynamic>> get mappedAllActivities {
    return recentActivities.map((activity) {
      String type = 'movement';
      if (activity.action == 'APPROVE' || activity.action == 'FINAL_APPROVE') {
        type = 'approval';
      } else if (activity.action == 'REJECT') {
        type = 'rejection';
      } else if (activity.action == 'SUBMIT') {
        type = 'submission';
      }

      return {
        "title": "${activity.checkpointName} ${activity.action}",
        "subtitle": "${activity.orderName}: ${activity.comment}",
        "timeAgo": _formatTimeAgo(activity.createdAt),
        "type": type,
        "orderId": activity.orderId,
      };
    }).toList();
  }

  String _formatTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays > 0) return '${duration.inDays}d ago';
    if (duration.inHours > 0) return '${duration.inHours}h ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  void navigateToFullActivityList() {
    Get.toNamed(Routes.clientActivities);
  }
}
