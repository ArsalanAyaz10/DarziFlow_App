import 'dart:ui';

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
  var formattedUserRole = ''.obs;

  // Department info
  var departmentName = ''.obs;
  var departmentId = ''.obs;
  var deptStatus = ''.obs;

  // Stats with realistic values
  var efficiencyScore = 0.obs;
  var totalOrders = 0.obs;
  var inProgressOrders = 0.obs;
  var completedOrders = 0.obs;
  var pendingCheckpoints = 0.obs;
  var overdueTasks = 0.obs;
  var avgCompletionTime = 0.0.obs;

  // Performance metrics
  var totalCheckpoints = 0.obs;
  var completedCheckpoints = 0.obs;
  var checkpointCompletionRate = 0.0.obs;
  var qualityScore = 0.obs;

  // For the stat cards
  var ordersTrend = '+0%'.obs;
  var queueSize = '0'.obs;

  // Activities
  var recentActivity = <dynamic>[].obs;
  var processedActivities = <Map<String, dynamic>>[].obs;

  // UI State
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Cache timestamps
  DateTime? _lastOverviewFetch;
  DateTime? _lastActivityFetch;
  static const Duration cacheDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (processedActivities.isEmpty) {
      isLoading.value = true;
    }

    errorMessage.value = '';

    try {
      // Load user info first since it doesn't depend on departmentId
      await loadUserInfo();
      
      // Then load overview which will set departmentId
      await fetchOverview();
      
      // Finally load activities using the departmentId
      if (departmentId.value.isNotEmpty) {
        await _loadActivities();
      } else {
        print("Warning: departmentId is empty, cannot load activities");
      }
      
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data';
      if (kDebugMode) {
        print("Dashboard Error: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    _lastOverviewFetch = null;
    _lastActivityFetch = null;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await loadUserInfo();
      await fetchOverview(forceRefresh: true);
      
      if (departmentId.value.isNotEmpty) {
        await _loadActivities(forceRefresh: true);
      }
      
    } catch (e) {
      errorMessage.value = 'Failed to refresh dashboard';
      if (kDebugMode) {
        print("Refresh Error: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserInfo() async {
    try {
      final user = await TokenStorage.getUser();
      userName.value = user?['name'] ?? 'User';
      final rawRole = user?['role'] ?? 'Department Head';
      formattedUserRole.value = _formatRole(rawRole);
      userRole.value = rawRole;
    } catch (e) {
      print("Error loading user info: $e");
    }
  }

  String _formatRole(String role) {
    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  Future<void> fetchOverview({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _lastOverviewFetch != null &&
        DateTime.now().difference(_lastOverviewFetch!) < cacheDuration) {
      return;
    }

    try {
      final data = await repository.fetchOverview();
      
      if (kDebugMode) {
        print("Overview data received: $data");
      }

      // Extract department info
      final dept = data['department'] ?? {};
      departmentName.value = dept['name'] ?? 'Department';
      deptStatus.value = dept['status'] ?? 'Unknown';
      departmentId.value = dept['_id'] ?? '';

      // Extract chart data
      final chart = data['chartData'] ?? {};
      
      // Try to get orders from different possible locations in the response
      List<dynamic> orders = [];
      
      if (data['orders'] != null) {
        orders = data['orders'] as List;
      } else if (data['recentOrders'] != null) {
        orders = data['recentOrders'] as List;
      } else if (data['data'] != null && data['data']['orders'] != null) {
        orders = data['data']['orders'] as List;
      }

      if (kDebugMode) {
        print("Found ${orders.length} orders");
      }

      // Calculate metrics even if orders are empty (will show zeros)
      _calculateMetrics(orders, chart);

      _lastOverviewFetch = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print("Overview Error: $e");
      }
      // Don't rethrow - we want to continue even if overview fails
    }
  }

  void _calculateMetrics(List<dynamic> orders, Map<String, dynamic> chart) {
    // Reset counters
    int total = 0;
    int inProgress = 0;
    int completed = 0;
    int totalCheckpointCount = 0;
    int completedCheckpointCount = 0;
    int rejectedCount = 0;
    int approvedCount = 0;
    List<Duration> completionTimes = [];

    DateTime now = DateTime.now();
    int overdueCount = 0;
    int pendingCheckpointCount = 0;

    // If we have chart data, use it as base
    if (chart.isNotEmpty) {
      total = chart['totalOrders'] ?? 0;
      inProgress = (chart['inProgress'] ?? 0) + (chart['pending'] ?? 0);
      completed = chart['completed'] ?? 0;
    }

    // Process each order for detailed metrics
    for (var order in orders) {
      total++; // Increment total for each order found
      
      final orderStatus = order['overallStatus'] ?? '';
      if (orderStatus == 'COMPLETED') {
        completed++;
      } else if (orderStatus == 'IN_PROGRESS') {
        inProgress++;
      }

      // Process workflow data
      final workflow = order['workflow'] as List? ?? [];
      
      for (var deptWorkflow in workflow) {
        // Check if this workflow section belongs to current department
        final deptId = deptWorkflow['departmentId']?['\$oid'] ?? 
                      deptWorkflow['departmentId']?.toString() ?? '';
        
        if (deptId == departmentId.value || departmentId.value.isEmpty) {
          final operations = deptWorkflow['operations'] as List? ?? [];
          
          for (var op in operations) {
            final checkpoints = op['checkpoints'] as List? ?? [];
            
            for (var checkpoint in checkpoints) {
              totalCheckpointCount++;
              
              final status = checkpoint['status'] ?? 'PENDING';
              if (status == 'COMPLETED' || status == 'APPROVED') {
                completedCheckpointCount++;
              } else if (status == 'PENDING' || status == 'IN_PROGRESS') {
                pendingCheckpointCount++;
              }

              // Check for overdue
              if (order['dueDate'] != null) {
                final dueDate = DateTime.tryParse(order['dueDate']);
                if (dueDate != null &&
                    dueDate.isBefore(now) &&
                    status != 'COMPLETED' &&
                    status != 'APPROVED') {
                  overdueCount++;
                }
              }

              // Process history
              final history = checkpoint['history'] as List? ?? [];
              for (var h in history) {
                final action = h['action'] ?? '';
                if (action == 'REJECT') {
                  rejectedCount++;
                } else if (action == 'APPROVE') {
                  approvedCount++;
                }
              }
            }
          }
        }
      }

      // Calculate completion time
      if (orderStatus == 'COMPLETED' &&
          order['createdAt'] != null &&
          order['updatedAt'] != null) {
        final created = DateTime.tryParse(order['createdAt']);
        final updated = DateTime.tryParse(order['updatedAt']);
        if (created != null && updated != null) {
          completionTimes.add(updated.difference(created));
        }
      }
    }

    // Set calculated values
    totalOrders.value = total;
    inProgressOrders.value = inProgress;
    completedOrders.value = completed;
    pendingCheckpoints.value = pendingCheckpointCount;
    overdueTasks.value = overdueCount;

    totalCheckpoints.value = totalCheckpointCount;
    completedCheckpoints.value = completedCheckpointCount;

    // Calculate completion rate
    if (totalCheckpointCount > 0) {
      checkpointCompletionRate.value =
          (completedCheckpointCount / totalCheckpointCount * 100)
              .roundToDouble();
    }

    // Calculate quality score
    final totalReviews = approvedCount + rejectedCount;
    if (totalReviews > 0) {
      qualityScore.value = (approvedCount / totalReviews * 100).round();
    } else {
      qualityScore.value = 100;
    }

    // Calculate average completion time
    if (completionTimes.isNotEmpty) {
      final totalDays = completionTimes
          .map((d) => d.inDays)
          .reduce((a, b) => a + b);
      avgCompletionTime.value = totalDays / completionTimes.length;
    }

    // Calculate efficiency score
    _calculateEfficiencyScore();

    // Calculate trend
    _calculateTrend();

    // Set queue size
    queueSize.value = pendingCheckpointCount.toString();

    if (kDebugMode) {
      print("Metrics calculated - Total Orders: $total, Checkpoints: $totalCheckpointCount, Activities: ${processedActivities.length}");
    }
  }

  void _calculateEfficiencyScore() {
    double score = 0;

    // Factor 1: Checkpoint completion rate (30% weight)
    if (totalCheckpoints.value > 0) {
      score += (completedCheckpoints.value / totalCheckpoints.value) * 30;
    }

    // Factor 2: Quality score (30% weight)
    score += (qualityScore.value / 100) * 30;

    // Factor 3: On-time performance (20% weight)
    if (totalCheckpoints.value > 0) {
      final onTimeRate = 1 - (overdueTasks.value / totalCheckpoints.value);
      score += onTimeRate * 20;
    }

    // Factor 4: Order completion rate (20% weight)
    if (totalOrders.value > 0) {
      final completionRate = completedOrders.value / totalOrders.value;
      score += completionRate * 20;
    }

    efficiencyScore.value = score.round();
  }

  void _calculateTrend() {
    if (totalOrders.value > 0) {
      final completionRate = completedOrders.value / totalOrders.value;

      if (completionRate > 0.7) {
        ordersTrend.value = '+15%';
      } else if (completionRate > 0.4) {
        ordersTrend.value = '+8%';
      } else if (completionRate > 0.2) {
        ordersTrend.value = '+3%';
      } else {
        ordersTrend.value = '-2%';
      }
    }
  }

  Future<void> _loadActivities({bool forceRefresh = false}) async {
    if (departmentId.value.isEmpty) {
      print("Cannot load activities: departmentId is empty");
      return;
    }

    if (!forceRefresh &&
        _lastActivityFetch != null &&
        DateTime.now().difference(_lastActivityFetch!) < cacheDuration) {
      return;
    }

    try {
      final activity = await repository.fetchActiveWorkflows(
        departmentId.value,
      );

      if (kDebugMode) {
        print("Loaded ${activity.length} activities");
      }

      recentActivity.value = activity;
      _processActivities();

      _lastActivityFetch = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print("Activity Error: $e");
      }
    }
  }

  void _processActivities() {
    final List<Map<String, dynamic>> processed = [];

    for (var order in recentActivity) {
      final orderName = order['orderName'] ?? 'Unknown Order';
      final orderUniqueId = order['orderUniqueId'] ?? '';
      final orderId = order['_id'] ?? '';
      
      // Truncate uniqueId safely
      String displayId = orderUniqueId;
      if (orderUniqueId.length > 6) {
        displayId = orderUniqueId.substring(0, 6);
      }

      final operations = order['operations'] as List? ?? [];

      for (var op in operations) {
        final checkpoints = op['checkpoints'] as List? ?? [];

        for (var checkpoint in checkpoints) {
          final checkpointName = checkpoint['name'] ?? 'Unknown Checkpoint';
          final history = checkpoint['history'] as List? ?? [];

          for (var h in history) {
            final action = h['action'] ?? '';
            final actedAt = h['actedAt'] ?? '';
            final comment = h['comment'] ?? '';

            String message;
            if (action == 'SUBMIT') {
              message = '$checkpointName submitted for review';
            } else if (action == 'APPROVE') {
              message = '$checkpointName approved';
            } else if (action == 'REJECT') {
              message = '$checkpointName rejected${comment.isNotEmpty ? ': $comment' : ''}';
            } else {
              message = '$checkpointName ${action.toLowerCase()}d';
            }

            processed.add({
              "orderId": orderId,
              "orderName": "Order #$displayId: $orderName",
              "message": message,
              "action": action,
              "actedAt": actedAt,
              "comment": comment,
              "type": _getActivityType(action, checkpointName),
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
    
    if (kDebugMode) {
      print("Processed ${processed.length} activities");
    }
  }

  String _getActivityType(String action, String checkpointName) {
    if (action == 'REJECT') return 'rejection';
    if (action == 'APPROVE') return 'approval';
    if (checkpointName.toLowerCase().contains('quality') ||
        checkpointName.toLowerCase().contains('inspection')) {
      return 'quality';
    }
    if (checkpointName.toLowerCase().contains('fabric') ||
        checkpointName.toLowerCase().contains('material')) {
      return 'material';
    }
    return 'movement';
  }

  void navigateToFullActivityList() {
    Get.toNamed(
      '/all-activities',
      arguments: {
        'departmentId': departmentId.value,
        'initialActivities': processedActivities.toList(),
      },
    );
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
    if (difference.inDays < 30) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  IconData getActivityIcon(String type) {
    switch (type) {
      case 'rejection':
        return Icons.cancel_outlined;
      case 'approval':
        return Icons.check_circle_outline;
      case 'quality':
        return Icons.verified_outlined;
      case 'material':
        return Icons.inventory_2_outlined;
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
      case 'quality':
        return Colors.purple;
      case 'material':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String getEfficiencyBreakdown() {
    return '''
Efficiency Score Breakdown:
• Checkpoint Completion: ${checkpointCompletionRate.value}%
• Quality Score: ${qualityScore.value}%
• On-Time Performance: ${_calculateOnTimePerformance()}%
• Order Completion: ${_calculateOrderCompletionRate()}%
''';
  }

  double _calculateOnTimePerformance() {
    if (totalCheckpoints.value == 0) return 100;
    return ((totalCheckpoints.value - overdueTasks.value) /
        totalCheckpoints.value *
        100);
  }

  double _calculateOrderCompletionRate() {
    if (totalOrders.value == 0) return 0;
    return (completedOrders.value / totalOrders.value * 100);
  }
}