import 'package:dariziflow_app/core/storage/token_storage.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/repositories/department_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeptHeadController extends GetxController {
  final DepartmentRepository repository;
  DeptHeadController({required this.repository});

  // USER INFO
  var userName = ''.obs;
  var userRole = ''.obs;
  var userAvatar = ''.obs;

  // DEPARTMENT INFO
  var departmentName = ''.obs;
  var departmentId = ''.obs;
  var deptStatus = ''.obs;

  //  Department Stats

  var templateOperations = 0.obs; // Total operations in template
  var templateCheckpoints = 0.obs; // Total checkpoints in template

  // ORDER STATS

  var totalOrders = 0.obs; // All orders with this department
  var inProgressOrders = 0.obs; // Orders with status IN_PROGRESS
  var pendingOrders = 0.obs; // Orders with status READY_TO_START/DOCS_PENDING
  var completedOrders = 0.obs; // Orders with status COMPLETED

  // OPERATION STATS

  var totalOperationsHandled = 0.obs; // Operations from started workflows
  var completedOps = 0.obs;
  var pendingOps = 0.obs;
  var inProgressOps = 0.obs;
  var rejectedOps = 0.obs;

  // CHECKPOINT STATS

  var totalCheckpoints = 0.obs;
  var completedCheckpoints = 0.obs;
  var pendingCheckpoints = 0.obs;
  var overdueCheckpoints = 0.obs;
  var checkpointCompletionRate = 0.0.obs;

  // QUALITY STATS

  var qualityScore = 100.obs; // Based on approve/reject
  var approvedCount = 0.obs;
  var rejectedCount = 0.obs;

  // EFFICIENCY & TRENDS

  var efficiencyScore = 0.obs;
  var ordersTrend = '+0%'.obs;
  var avgCompletionTime = 0.0.obs;

  // ACTIVITIES

  var recentActivity = <dynamic>[].obs;
  var processedActivities = <Map<String, dynamic>>[].obs;

  // UI

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // CACHE

  DateTime? _lastActivityFetch;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    _setLoadingState(true);
    _clearErrorMessage();

    try {
      await _loadUserInfo();

      final user = await TokenStorage.getUser();
      if (user != null && user['department'] != null) {
        departmentId.value = user['department'];
      }

      await _loadAllDepartmentStats(forceRefresh: true);
      await _loadActivities();
    } catch (e) {
      _handleError('Failed to load dashboard data', e);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> refreshDashboard() async {
    _invalidateCache();
    _setLoadingState(true);
    _clearErrorMessage();

    try {
      await _loadUserInfo();

      final deptId = await _getUserDepartmentId();
      if (deptId != null) {
        departmentId.value = deptId;
      }

      // Load fresh stats
      await _loadAllDepartmentStats(forceRefresh: true);
      await _loadActivities(forceRefresh: true);
    } catch (e) {
      _handleError('Failed to refresh dashboard', e);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _loadAllDepartmentStats({bool forceRefresh = false}) async {
    try {
      final data = await repository.fetchOverview();

      if (kDebugMode) {
        print("📊 FULL OVERVIEW DATA: $data");
      }

      // Extract department info
      final dept = data['department'] ?? {};
      departmentName.value = dept['name'] ?? 'Department';
      deptStatus.value = dept['status'] ?? 'Unknown';
      departmentId.value = dept['_id'] ?? '';

      // Load template stats
      final templateStats = data['templateStats'] ?? {};
      templateOperations.value = templateStats['totalOperations'] ?? 0;
      templateCheckpoints.value = templateStats['totalCheckpoints'] ?? 0;

      // Load order stats
      final orderStats = data['orderStats'] ?? {};
      totalOrders.value = orderStats['totalOrders'] ?? 0;
      inProgressOrders.value = orderStats['inProgress'] ?? 0;
      pendingOrders.value = orderStats['pending'] ?? 0;
      completedOrders.value = orderStats['completed'] ?? 0;

      // Load operation stats
      final opStats = data['operationStats'] ?? {};
      totalOperationsHandled.value = opStats['totalOperationsHandled'] ?? 0;
      completedOps.value = opStats['completed'] ?? 0;
      pendingOps.value = opStats['pending'] ?? 0;
      inProgressOps.value = opStats['inProgress'] ?? 0;
      rejectedOps.value = opStats['rejected'] ?? 0;

      // if (kDebugMode) {
      //   print("📊 ORDER STATS LOADED:");
      //   print("   totalOrders: ${totalOrders.value}");
      //   print("   inProgressOrders: ${inProgressOrders.value}");
      //   print("   pendingOrders: ${pendingOrders.value}");
      //   print("   completedOrders: ${completedOrders.value}");

      //   print("📊 TEMPLATE STATS:");
      //   print("   operations: ${templateOperations.value}");
      //   print("   checkpoints: ${templateCheckpoints.value}");
      // }


      _calculateCheckpointStats();
      _calculateQualityScore();
      _calculateEfficiencyScore();
      _calculateTrend();
    } catch (e) {
      if (kDebugMode) print("Error loading stats: $e");
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await TokenStorage.getUser();
      userName.value = user?['name'] ?? 'User';
      userRole.value = _formatUserRole(user?['role'] ?? '');
      _loadUserAvatar(user);
    } catch (e) {
      if (kDebugMode) print("Error loading user info: $e");
    }
  }

  void _loadUserAvatar(Map<String, dynamic>? user) {
    if (user != null && user['avatar'] != null) {
      if (user['avatar'] is Map) {
        userAvatar.value = user['avatar']['url'] ?? '';
      } else if (user['avatar'] is String) {
        userAvatar.value = user['avatar'];
      } else {
        userAvatar.value = '';
      }
    } else {
      userAvatar.value = '';
    }
  }

  Future<void> _loadActivities({bool forceRefresh = false}) async {
    if (departmentId.value.isEmpty) return;
    if (!forceRefresh && _isActivityCacheValid()) return;

    try {
      final activity = await repository.fetchActiveWorkflows(
        departmentId.value,
      );
      recentActivity.value = activity;
      _processActivities();
      _lastActivityFetch = DateTime.now();
    } catch (e) {
      if (kDebugMode) print("Activity Error: $e");
    }
  }

  // ==================== CALCULATION METHODS ====================

  void _calculateCheckpointStats() {
    totalCheckpoints.value = totalOperationsHandled.value * 2;
    completedCheckpoints.value = completedOps.value;
    pendingCheckpoints.value = pendingOps.value + inProgressOps.value;

    if (totalCheckpoints.value > 0) {
      checkpointCompletionRate.value =
          (completedCheckpoints.value / totalCheckpoints.value * 100)
              .roundToDouble();
    }
  }

  void _calculateQualityScore() {
    if (totalOperationsHandled.value > 0) {
      final qualityValue =
          100 - (rejectedOps.value / totalOperationsHandled.value * 100);
      qualityScore.value = qualityValue.round();
    }
  }

  void _calculateEfficiencyScore() {
    if (totalOperationsHandled.value == 0) {
      efficiencyScore.value = 0;
      return;
    }

    double score = 0;

    score += (completedOps.value / totalOperationsHandled.value) * 40;

    score += (qualityScore.value / 100) * 30;

    if (totalOrders.value > 0) {
      score += (completedOrders.value / totalOrders.value) * 30;
    }

    efficiencyScore.value = score.round();
  }

  void _calculateTrend() {
    if (totalOrders.value > 0) {
      if (inProgressOrders.value > 5) {
        ordersTrend.value = '+15%';
      } else if (inProgressOrders.value > 2) {
        ordersTrend.value = '+8%';
      } else if (inProgressOrders.value > 0) {
        ordersTrend.value = '+3%';
      } else {
        ordersTrend.value = '0%';
      }
    }
  }

  // ACTIVITY PROCESSING

  void _processActivities() {
    final List<Map<String, dynamic>> processed = [];

    for (var order in recentActivity) {
      final orderName = order['orderName'] ?? 'Unknown Order';
      final orderUniqueId = order['orderUniqueId'] ?? '';
      final orderId = order['_id'] ?? '';
      final progress = order['progress'] ?? 0;

      String displayId = orderUniqueId.length > 6
          ? orderUniqueId.substring(0, 6)
          : orderUniqueId;

      processed.add({
        "orderId": orderId,
        "orderName": "Order #$displayId: $orderName",
        "progress": progress,
        "dueDate": order['dueDate'],
        "operations": (order['operations'] as List?)?.length ?? 0,
        "message": _generateActivityMessage(order),
      });
    }

    processedActivities.value = processed;
  }

  String _generateActivityMessage(Map<String, dynamic> order) {
    final progress = order['progress'] ?? 0;
    if (progress == 100) return "All operations completed";
    if (progress > 0) return "$progress% complete";
    return "Ready to start";
  }

  bool _isActivityCacheValid() {
    return _lastActivityFetch != null &&
        DateTime.now().difference(_lastActivityFetch!) < cacheDuration;
  }

  void _invalidateCache() {
    _lastActivityFetch = null;
  }

  // UI Loader and Error Handling

  void _setLoadingState(bool loading) {
    isLoading.value = loading;
  }

  void _clearErrorMessage() {
    errorMessage.value = '';
  }

  void _handleError(String message, dynamic error) {
    errorMessage.value = message;
    if (kDebugMode) print("$message: $error");
  }

  String _formatUserRole(String role) {
    switch (role) {
      case 'CLIENT':
        return 'Client';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'QC_MEMBER':
        return 'QC Member';
      default:
        return 'Unknown Role';
    }
  }

  Color getStatusColor() {
    switch (deptStatus.value) {
      case 'ACTIVE':
        return Colors.green;
      case 'INACTIVE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double getOrderCompletionRate() {
    if (totalOrders.value == 0) return 0;
    return (completedOrders.value / totalOrders.value * 100);
  }

  double getOperationCompletionRate() {
    if (totalOperationsHandled.value == 0) return 0;
    return (completedOps.value / totalOperationsHandled.value * 100);
  }

  // NAVIGATION

  void navigateToFullActivityList() {
    Get.toNamed(
      '/all-activities',
      arguments: {
        'departmentId': departmentId.value,
        'activities': processedActivities.toList(),
      },
    );
  }

  String formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData getActivityIcon(String type) {
    switch (type) {
      case 'rejection':
        return Icons.cancel_outlined;
      case 'approval':
        return Icons.check_circle_outline;
      default:
        return Icons.compare_arrows_outlined;
    }
  }

  Color getActivityColor(String type) {
    switch (type) {
      case 'rejection':
        return Colors.red;
      case 'approval':
        return Colors.green;
      default:
        return Colors.blue;
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

  Future<String?> _getUserDepartmentId() async {
    try {
      final user = await TokenStorage.getUser();
      if (user != null && user['department'] != null) {
        return user['department'].toString();
      }
    } catch (e) {
      if (kDebugMode) print("Error getting user department: $e");
    }
    return null;
  }
}
