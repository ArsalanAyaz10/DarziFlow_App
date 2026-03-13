import 'package:dariziflow_app/core/storage/storage.dart';
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

  // Department Template Stats
  var templateOperations = 0.obs;
  var templateCheckpoints = 0.obs;

  // ORDER STATS
  var totalOrders = 0.obs;
  var inProgressOrders = 0.obs;
  var pendingOrders = 0.obs;
  var completedOrders = 0.obs;

  // OPERATION STATS
  var totalOperationsHandled = 0.obs;
  var completedOps = 0.obs;
  var pendingOps = 0.obs;
  var inProgressOps = 0.obs;
  var rejectedOps = 0.obs;

  // CHECKPOINT STATS
  var totalCheckpointsInWorkflow = 0.obs;
  var completedWorkflowCheckpoints = 0.obs;
  var pendingWorkflowCheckpoints = 0.obs;

  // LEGACY CHECKPOINT STATS (for backward compatibility)
  var totalCheckpoints = 0.obs;
  var completedCheckpoints = 0.obs;
  var pendingCheckpoints = 0.obs;
  var overdueCheckpoints = 0.obs;
  var checkpointCompletionRate = 0.0.obs;

  // QUALITY STATS
  var qualityScore = 100.obs;
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

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _loadUserInfo();

      final user = await AppStorage.getUser();
      if (user != null && user['department'] != null) {
        departmentId.value = user['department'];
      }

      await _loadAllDepartmentStats(forceRefresh: true);
      await _loadActivities();
    } catch (e) {
      _handleError('Failed to load dashboard data', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _loadUserInfo();

      final deptId = await _getUserDepartmentId();
      if (deptId != null) {
        departmentId.value = deptId;
      }

      await _loadAllDepartmentStats(forceRefresh: true);
      await _loadActivities();
    } catch (e) {
      _handleError('Failed to refresh dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllDepartmentStats({bool forceRefresh = false}) async {
    try {
      final data = await repository.fetchOverview();

      final dept = data['department'] ?? {};
      departmentName.value = dept['name'] ?? 'No Department';
      deptStatus.value = dept['status'] ?? 'Unknown';
      departmentId.value = dept['_id'] ?? '';

      final templateStats = data['templateStats'] ?? {};
      templateOperations.value = templateStats['totalOperations'] ?? 0;
      templateCheckpoints.value = templateStats['totalCheckpoints'] ?? 0;

      final orderStats = data['orderStats'] ?? {};
      totalOrders.value = orderStats['totalOrders'] ?? 0;
      inProgressOrders.value = orderStats['inProgress'] ?? 0;
      pendingOrders.value = orderStats['pending'] ?? 0;
      completedOrders.value = orderStats['completed'] ?? 0;

      final opStats = data['operationStats'] ?? {};
      totalOperationsHandled.value = opStats['totalOperationsHandled'] ?? 0;
      completedOps.value = opStats['completed'] ?? 0;
      pendingOps.value = opStats['pending'] ?? 0;
      inProgressOps.value = opStats['inProgress'] ?? 0;
      rejectedOps.value = opStats['rejected'] ?? 0;

      final checkpointStats = data['checkpointStats'] ?? {};
      totalCheckpointsInWorkflow.value =
          checkpointStats['totalCheckpoints'] ?? 0;
      completedWorkflowCheckpoints.value = checkpointStats['completed'] ?? 0;
      pendingWorkflowCheckpoints.value = checkpointStats['pending'] ?? 0;

      final qualityStats = data['qualityStats'] ?? {};
      qualityScore.value = qualityStats['score'] ?? 100;
      approvedCount.value = qualityStats['approved'] ?? 0;
      rejectedCount.value = qualityStats['rejected'] ?? 0;

      _updateLegacyCheckpointStats();
      _calculateCheckpointCompletionRate();
      _calculateEfficiencyScore();
      _calculateTrend();
    } catch (e) {
      if (kDebugMode) print("Error loading stats: $e");
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await AppStorage.getUser();
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

  // ==================== CALCULATION METHODS ====================

  void _updateLegacyCheckpointStats() {
    totalCheckpoints.value = totalCheckpointsInWorkflow.value;
    completedCheckpoints.value = completedWorkflowCheckpoints.value;
    pendingCheckpoints.value = pendingWorkflowCheckpoints.value;
  }

  void _calculateCheckpointCompletionRate() {
    if (totalCheckpointsInWorkflow.value > 0) {
      checkpointCompletionRate.value =
          (completedWorkflowCheckpoints.value /
                  totalCheckpointsInWorkflow.value *
                  100)
              .roundToDouble();
    } else {
      checkpointCompletionRate.value = 0;
    }
  }

  void _calculateEfficiencyScore() {
    if (totalOperationsHandled.value == 0 &&
        totalCheckpointsInWorkflow.value == 0) {
      efficiencyScore.value = 0;
      return;
    }

    double score = 0;
    double totalWeight = 0;

    if (totalOperationsHandled.value > 0) {
      double opRate = completedOps.value / totalOperationsHandled.value;
      score += opRate * 25;
      totalWeight += 25;
    }

    if (totalCheckpointsInWorkflow.value > 0) {
      double checkpointRate =
          completedWorkflowCheckpoints.value / totalCheckpointsInWorkflow.value;
      score += checkpointRate * 45;
      totalWeight += 45;
    }

    score += (qualityScore.value / 100) * 30;
    totalWeight += 30;

    if (totalWeight > 0) {
      efficiencyScore.value = (score / totalWeight * 100).round();
    } else {
      efficiencyScore.value = 0;
    }
  }

  Future<String?> _getUserDepartmentId() async {
    try {
      final user = await AppStorage.getUser();
      if (user != null && user['department'] != null) {
        return user['department'].toString();
      }
    } catch (e) {
      if (kDebugMode) print("Error getting user department: $e");
    }
    return null;
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

  double getOrderCompletionRate() {
    if (totalOrders.value == 0) return 0;
    return (completedOrders.value / totalOrders.value * 100);
  }

  double getOperationCompletionRate() {
    if (totalOperationsHandled.value == 0) return 0;
    return (completedOps.value / totalOperationsHandled.value * 100);
  }

  double getCheckpointCompletionRate() {
    if (totalCheckpointsInWorkflow.value == 0) return 0;
    return (completedWorkflowCheckpoints.value /
        totalCheckpointsInWorkflow.value *
        100);
  }

  // ==================== ACTIVITY PROCESSING ====================

  Future<void> _loadActivities() async {
    try {
      final activity = await repository.fetchActiveWorkflows(
        departmentId.value,
      );
      recentActivity.value = activity;
      _processActivities();
    } catch (e) {
      if (kDebugMode) print("Activity Error: $e");
    }
  }

  void _processActivities() {
    final List<Map<String, dynamic>> processed = [];

    for (var order in recentActivity) {
      final orderName = order['orderName'] ?? 'Unknown Order';
      final orderUniqueId = order['orderUniqueId'] ?? '';
      final orderId = order['_id'] ?? '';
      final operations = order['operations'] as List? ?? [];
      final updatedAt = order['updatedAt'] ?? order['createdAt'];

      String displayId = orderUniqueId.length > 6
          ? orderUniqueId.substring(0, 6)
          : orderUniqueId;

      // 1. Add movement activity (when order enters department)
      processed.add({
        "id": "${orderId}_movement",
        "type": "movement",
        "title": "Order #$displayId: $orderName",
        "subtitle": "Moved to ${departmentName.value} department",
        "timeAgo": _calculateTimeAgo(updatedAt),
        "action": "MOVE",
        "orderId": orderId,
        "iconData": Icons.swap_horiz,
        "color": Colors.blue,
      });

      // 2. Check for material alerts (can be extended based on actual data)
      if (_hasLowMaterialAlert(order)) {
        processed.add({
          "id": "${orderId}_alert",
          "type": "alert",
          "title": "Low Material Alert",
          "subtitle": _getMaterialAlertMessage(order),
          "timeAgo": _calculateTimeAgo(updatedAt),
          "action": "ALERT",
          "orderId": orderId,
          "iconData": Icons.warning_amber_rounded,
          "color": Colors.orange,
        });
      }

      // 3. Check for operator assignments
      if (_hasNewAssignment(order)) {
        processed.add({
          "id": "${orderId}_assignment",
          "type": "assignment",
          "title": "New Operator Assigned",
          "subtitle": _getAssignmentMessage(order),
          "timeAgo": _calculateTimeAgo(updatedAt),
          "action": "ASSIGN",
          "orderId": orderId,
          "iconData": Icons.person_add_alt,
          "color": Colors.purple,
        });
      }

      // 4. Process operations and checkpoints for detailed activities
      for (var op in operations) {
        final opName = op['name'] ?? 'Unknown Operation';
        final checkpoints = op['checkpoints'] as List? ?? [];

        for (var checkpoint in checkpoints) {
          final checkpointName = checkpoint['name'] ?? 'Unknown Checkpoint';
          final history = checkpoint['history'] as List? ?? [];

          for (var h in history) {
            final action = h['action'] ?? '';
            final actedAt = h['actedAt'] ?? updatedAt;
            final comment = h['comment'] ?? '';

            if (action.isNotEmpty) {
              final activityData = _createActivityFromHistory(
                action: action,
                orderId: orderId,
                displayId: displayId,
                orderName: orderName,
                checkpointName: checkpointName,
                opName: opName,
                actedAt: actedAt,
                comment: comment,
              );

              if (activityData != null) {
                processed.add(activityData);
              }
            }
          }
        }
      }
    }

    // Sort by time (newest first)
    processed.sort((a, b) {
      final aTime = _parseTimeAgo(a['timeAgo']);
      final bTime = _parseTimeAgo(b['timeAgo']);
      return bTime.compareTo(aTime);
    });

    processedActivities.value = processed;
  }

  Map<String, dynamic>? _createActivityFromHistory({
    required String action,
    required String orderId,
    required String displayId,
    required String orderName,
    required String checkpointName,
    required String opName,
    required String actedAt,
    String comment = '',
  }) {
    String type;
    IconData iconData;
    Color color;
    String subtitle;

    switch (action) {
      case 'SUBMIT':
        type = 'submission';
        iconData = Icons.upload_file;
        color = Colors.green;
        subtitle = "$checkpointName submitted for review";
        break;
      case 'APPROVE':
        type = 'approval';
        iconData = Icons.check_circle;
        color = Colors.green;
        subtitle = "$checkpointName approved";
        break;
      case 'FINAL_APPROVE':
        type = 'approval';
        iconData = Icons.task_alt;
        color = Colors.green;
        subtitle = "$checkpointName finalized";
        break;
      case 'REJECT':
        type = 'rejection';
        iconData = Icons.cancel;
        color = Colors.red;
        subtitle = comment.isNotEmpty
            ? "$checkpointName rejected: $comment"
            : "$checkpointName rejected";
        break;
      default:
        return null;
    }

    return {
      "id": "${orderId}_${action}_$actedAt",
      "type": type,
      "title": "Order #$displayId: $orderName",
      "subtitle": subtitle,
      "timeAgo": _calculateTimeAgo(actedAt),
      "action": action,
      "orderId": orderId,
      "iconData": iconData,
      "color": color,
    };
  }

  String _calculateTimeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }

  DateTime _parseTimeAgo(String timeAgo) {
    // This is a simplified parser - for sorting purposes
    if (timeAgo.contains('m')) {
      final minutes = int.tryParse(timeAgo.replaceAll('m ago', '')) ?? 0;
      return DateTime.now().subtract(Duration(minutes: minutes));
    } else if (timeAgo.contains('h')) {
      final hours = int.tryParse(timeAgo.replaceAll('h ago', '')) ?? 0;
      return DateTime.now().subtract(Duration(hours: hours));
    } else if (timeAgo.contains('d')) {
      final days = int.tryParse(timeAgo.replaceAll('d ago', '')) ?? 0;
      return DateTime.now().subtract(Duration(days: days));
    }
    return DateTime.now();
  }

  bool _hasLowMaterialAlert(Map<String, dynamic> order) {
    // This should be implemented based on actual data
    // For now, return false as placeholder
    return false;
  }

  bool _hasNewAssignment(Map<String, dynamic> order) {
    // This should be implemented based on actual data
    // For now, return false as placeholder
    return false;
  }

  String _getMaterialAlertMessage(Map<String, dynamic> order) {
    return "Thread count low for Batch B-12";
  }

  String _getAssignmentMessage(Map<String, dynamic> order) {
    return "Maria G. assigned to Table 4";
  }

  void navigateToFullActivityList() {
    print(
      "🔄 Navigating to all-activities with ${processedActivities.length} activities",
    );
    print("Current route: ${Get.currentRoute}");

    Get.toNamed(
          '/all-activities',
          arguments: {
            'departmentId': departmentId.value,
            'activities': processedActivities.toList(),
          },
        )
        ?.then((value) {
          print("Returned from all-activities with: $value");
        })
        .catchError((error) {
          print("Navigation error: $error");
        });
  }

  // ==================== UI HELPERS ====================

  void _handleError(String message, dynamic error) {
    errorMessage.value = message;
    if (kDebugMode) print("$message: $error");
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
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
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
}
