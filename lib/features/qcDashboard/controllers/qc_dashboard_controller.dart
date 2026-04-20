import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/features/qcDashboard/repositories/qc_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class QcDashboardController extends GetxController {
  final QcRepository repository;
  QcDashboardController({required this.repository});

  // USER INFO
  var userName = ''.obs;
  var userRole = ''.obs;
  var userAvatar = ''.obs;

  // QC GLOBAL STATS (From /qc/getStats)
  var pendingReviewsCount = 0.obs;
  var approvedTodayCount = 0.obs;
  var rejectedTodayCount = 0.obs;

  // PENDING SUBMISSIONS (From /qc/submissions/pending)
  var pendingSubmissions = <Map<String, dynamic>>[].obs;

  // REJECTION REASONS (From /qc/rejection-reasons)
  var rejectionReasons = <String>[].obs;

  // UI STATE
  var isLoading = false.obs;
  var isActionLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Initial Load for UI display
    _loadUserInfo();
    // 2. Strict Requirement: Initial data fetch calls exclusively the 3 global endpoints via refreshDashboard()
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
      await Future.wait([
        _loadStats(),
        _loadPendingSubmissions(),
      ]);
    } catch (e) {
      dev.log("Error refreshing Global QC dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadStats() async {
    final stats = await repository.fetchStats();
    // Binding to /{pending_reviews, approved_today, rejected_today}
    pendingReviewsCount.value = stats['pending_reviews'] ?? 0;
    approvedTodayCount.value = stats['approved_today'] ?? 0;
    rejectedTodayCount.value = stats['rejected_today'] ?? 0;
  }

  Future<void> _loadPendingSubmissions() async {
    final submissions = await repository.fetchPendingSubmissions();
    pendingSubmissions.value = submissions.cast<Map<String, dynamic>>();
  }

  // ACTIONS (Standard QC workflow)
  Future<void> approveSubmission(String orderId, String opId, String chkId) async {
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
}
