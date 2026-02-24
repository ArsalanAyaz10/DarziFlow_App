import 'package:dariziflow_app/features/dept_head/repository/department_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/token_storage.dart';

class DeptHeadController extends GetxController {
  final DepartmentRepository repository;
  DeptHeadController({required this.repository});

  // User info
  var userName = ''.obs;
  var userRole = ''.obs;

  // Department info
  var departmentName = ''.obs;
  var departmentId = ''.obs;
  var deptStatus = ''.obs;

  // Stats
  var efficiencyScore = 0.obs;
  var totalOrders = 0.obs;
  var inProgressOrders = 0.obs;

  // Activities - Raw data from API
  var recentActivity = <dynamic>[].obs;

  // Processed activities for display
  var processedActivities = <Map<String, dynamic>>[].obs;

  // Pagination
  var currentPage = 0.obs;
  var hasMorePages = true.obs;
  var isLoadingMore = false.obs; 
  static const int pageSize = 10;

  // UI State
  var isLoading = false.obs;
  var isInitialized = false.obs;
  var errorMessage = ''.obs;

  // Cache timestamps
  DateTime? _lastOverviewFetch;
  DateTime? _lastActivityFetch;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await loadUserInfo();
      await fetchOverview();

      if (departmentId.value.isNotEmpty) {
        await fetchActivity(resetPagination: true);
      }

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data';
      if (kDebugMode) {
        print("Initialization Error: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    // Clear cache on manual refresh
    _lastOverviewFetch = null;
    _lastActivityFetch = null;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await loadUserInfo();
      await fetchOverview(forceRefresh: true);
      if (departmentId.value.isNotEmpty) {
        await fetchActivity(forceRefresh: true, resetPagination: true);
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh dashboard';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserInfo() async {
    final user = await TokenStorage.getUser();
    userName.value = user?['name'] ?? 'User';
    userRole.value = user?['role'] ?? 'Department Head';
  }

  Future<void> fetchOverview({bool forceRefresh = false}) async {
    // Check cache
    if (!forceRefresh &&
        _lastOverviewFetch != null &&
        DateTime.now().difference(_lastOverviewFetch!) < cacheDuration) {
      return;
    }

    try {
      final data = await repository.fetchOverview();

      final dept = data['department'] ?? {};
      final chart = data['chartData'] ?? {};

      departmentName.value = dept['name'] ?? 'Department';
      deptStatus.value = dept['status'] ?? 'Unknown';
      departmentId.value = dept['_id'] ?? '';

      totalOrders.value = chart['totalOperationsHandled'] ?? 0;
      inProgressOrders.value =
          (chart['inProgress'] ?? 0) + (chart['pending'] ?? 0);

      _lastOverviewFetch = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print("Overview Error: $e");
      }
      rethrow;
    }
  }

  // Modified fetchActivity without pagination
  Future<void> fetchActivity({
    bool forceRefresh = false,
    bool resetPagination = false,
  }) async {
    // Check cache
    if (!forceRefresh &&
        _lastActivityFetch != null &&
        DateTime.now().difference(_lastActivityFetch!) < cacheDuration) {
      return;
    }

    try {
      // Call repository without pagination parameters
      final activity = await repository.fetchActiveWorkflows(
        departmentId.value,
      );

      if (resetPagination) {
        recentActivity.clear();
        processedActivities.clear();
      }

      // Add new activities
      recentActivity.addAll(activity);

      // Process all activities for display
      _processActivities();

      _lastActivityFetch = DateTime.now();

      // Since we don't have pagination, always set hasMorePages to false
      hasMorePages.value = false;
    } catch (e) {
      if (kDebugMode) {
        print("Activity Error: $e");
      }
      rethrow;
    }
  }

  // Simplified loadMoreActivities (won't actually load more)
  Future<void> loadMoreActivities() async {
    // Just show a message or do nothing since pagination isn't supported
    if (kDebugMode) {
      print("Pagination not supported yet");
    }
  }

  void _processActivities() {
    final List<Map<String, dynamic>> processed = [];

    for (var order in recentActivity) {
      final operations = order['operations'] as List? ?? [];

      for (var op in operations) {
        final checkpoints = op['checkpoints'] as List? ?? [];

        for (var checkpoint in checkpoints) {
          final history = checkpoint['history'] as List? ?? [];

          for (var h in history) {
            processed.add({
              "orderId": order['_id'],
              "orderName": order['orderName'],
              "checkpointName": checkpoint['name'],
              "action": h['action'],
              "actedAt": h['actedAt'],
              "comment": h['comment'],
            });
          }
        }
      }
    }

    // Sort by date (latest first)
    processed.sort((a, b) {
      final aDate = DateTime.tryParse(a['actedAt'] ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['actedAt'] ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    processedActivities.value = processed;
  }

  // Helper methods for UI
  String getActionColor(String action) {
    switch (action) {
      case 'APPROVE':
        return 'green';
      case 'REJECT':
        return 'red';
      case 'SUBMIT':
        return 'blue';
      default:
        return 'grey';
    }
  }

  IconData getActionIcon(String action) {
    switch (action) {
      case 'APPROVE':
        return Icons.check_circle;
      case 'REJECT':
        return Icons.cancel;
      case 'SUBMIT':
        return Icons.upload_file;
      default:
        return Icons.info;
    }
  }

  String formatReadableMessage(String action, String checkpoint) {
    switch (action) {
      case 'SUBMIT':
        return "$checkpoint submitted";
      case 'APPROVE':
        return "$checkpoint approved";
      case 'REJECT':
        return "$checkpoint rejected";
      default:
        return "$checkpoint updated";
    }
  }

  String formatTimeAgo(DateTime? date) {
    if (date == null) return '';

    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Navigate to full activity list
  void navigateToFullActivityList() {
    Get.toNamed(
      '/all-activities',
      arguments: {
        'departmentId': departmentId.value,
        'initialActivities': processedActivities.toList(),
      },
    );
  }
}
