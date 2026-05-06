import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/QualityControl/repositories/qc_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class QcDashboardController extends GetxController {
  final QcRepository repository;
  final OrderRepository orderRepository; // <-- Added OrderRepository

  QcDashboardController({
    required this.repository,
    required this.orderRepository, // <-- Required in constructor
  });

  // USER INFO
  var userName = ''.obs;
  var userRole = ''.obs;
  var userAvatar = ''.obs;

  // QC GLOBAL
  var pendingReviewsCount = 0.obs;
  var approvedTodayCount = 0.obs;
  var rejectedTodayCount = 0.obs;

  // PENDING SUBMISSIONS
  var pendingSubmissions = <Map<String, dynamic>>[].obs;

  // ACTIVE ORDERS PIPELINE (NEW)
  var activeOrders = <OrderModel>[].obs; // <-- Holds the real pipeline data

  // REJECTION
  var rejectionReasons = <String>[].obs;

  // UI
  var isLoading = false.obs;
  var isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    refreshDashboard();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AppStorage.getAuthUser();
      if (user == null) return;
      userName.value = user.name;
      userRole.value = user.formattedRole;
      userAvatar.value = user.avatarUrl;
    } catch (e) {
      if (kDebugMode) dev.log("Error loading user info: $e");
    }
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    try {
      // Run all three fetches in parallel for maximum speed
      await Future.wait([
        _loadStats(),
        _loadPendingSubmissions(),
        _loadActiveOrders(), // <-- Added to the refresh cycle
      ]);
    } catch (e) {
      dev.log("Error refreshing Global QC dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await repository.fetchStats();
      pendingReviewsCount.value = stats['pending_reviews'] ?? 0;
      approvedTodayCount.value = stats['approved_today'] ?? 0;
      rejectedTodayCount.value = stats['rejected_today'] ?? 0;
    } catch (e) {
      if (kDebugMode) dev.log("Error loading QC stats: $e");
    }
  }

  Future<void> _loadPendingSubmissions() async {
    try {
      final submissions = await repository.fetchPendingSubmissions();
      pendingSubmissions.value = submissions.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) dev.log("Error loading pending submissions: $e");
    }
  }

  // --- NEW: Load Active Pipeline ---
  Future<void> _loadActiveOrders() async {
    try {
      // Fetch all orders assigned to this QC (from the /api/orders endpoint)
      final rawData = await orderRepository.fetchAllOrders();

      // Parse them using your OrderModel
      final parsedOrders = rawData
          .map((json) => OrderModel.fromJson(json))
          .toList();

      // Filter out completed ones so the pipeline only shows active work
      activeOrders.value = parsedOrders
          .where((o) => o.overallStatus != 'COMPLETED')
          .toList();
    } catch (e) {
      if (kDebugMode) dev.log("Error loading active orders for pipeline: $e");
    }
  }

  Future<void> approveSubmission(
    String orderId,
    String opId,
    String chkId,
  ) async {
    isActionLoading.value = true;
    try {
      final success = await repository.approveSubmission(
        orderId: orderId,
        opId: opId,
        chkId: chkId,
      );

      if (success) {
        Get.snackbar(
          "Success",
          "Submission approved successfully",
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          colorText: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
        );
        await refreshDashboard();
      } else {
        Get.snackbar("Error", "Failed to approve submission");
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> rejectSubmission(
    String orderId,
    String opId,
    String chkId,
    String comment,
  ) async {
    if (comment.isEmpty) {
      Get.snackbar("Error", "Feedback comment is mandatory for rejection");
      return;
    }

    isActionLoading.value = true;
    try {
      final success = await repository.rejectSubmission(
        orderId: orderId,
        opId: opId,
        chkId: chkId,
        comment: comment,
      );

      if (success) {
        Get.snackbar(
          "Rejected",
          "Submission has been sent back for rework",
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          colorText: Colors.orange,
          snackPosition: SnackPosition.BOTTOM,
        );
        await refreshDashboard();
      } else {
        Get.snackbar("Error", "Failed to reject submission");
      }
    } finally {
      isActionLoading.value = false;
    }
  }

  String formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Just now';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
