import 'package:dariziflow_app/features/DepartmentHead/repositories/department_repository.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class DepartmentDetailsController extends GetxController {
  final DepartmentRepository repository;
  final String departmentId;

  DepartmentDetailsController({required this.repository, required this.departmentId});

  var isLoading = true.obs;
  
  var name = ''.obs;
  var description = ''.obs;
  var status = ''.obs;
  var managerName = ''.obs;
  var managerEmail = ''.obs;
  var operations = <dynamic>[].obs;
  
  // STATS
  var totalOrders = 0.obs;
  var activeOrders = 0.obs;
  
  // ACTIVITIES
  final _recentActivity = <dynamic>[].obs;
  var processedActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      var data = await repository.fetchDepartmentById(departmentId);
      
      if (data.isEmpty) {
        final rawResponse = await repository.service.getDepartmentById(departmentId);
        if (rawResponse is Map<String, dynamic>) {
           if (rawResponse.containsKey('department')) {
               data = rawResponse['department'];
           } else {
               data = rawResponse;
           }
        }
      }

      name.value = data['name'] ?? 'Unknown';
      description.value = data['description'] ?? '';
      status.value = data['status'] ?? 'Unknown';

      if (data['departmentHead'] != null) {
        managerName.value = data['departmentHead']['name'] ?? 'Department Head';
        managerEmail.value = data['departmentHead']['email'] ?? '';
      } else {
        managerName.value = 'Department Head';
        managerEmail.value = 'No email available';
      }

      final opsList = data['operations'] as List? ?? [];
      operations.assignAll(opsList);

      await _loadOrderStats();
      await _loadActivities();

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch department details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadOrderStats() async {
    try {
      final stats = await repository.fetchOrderStats(departmentId);
      totalOrders.value = stats['totalOrders'] ?? 0;
      activeOrders.value = stats['inProgress'] ?? 0;
    } catch (e) {
      dev.log("Order Stats Error: $e");
    }
  }

  // ==================== Activity process ====================

  Future<void> _loadActivities() async {
    try {
      final activity = await repository.fetchActiveWorkflows(departmentId);
      _recentActivity.value = activity;
      _processActivities();
    } catch (e) {
      dev.log("Activity Error: $e");
    }
  }

  void _processActivities() {
    final List<Map<String, dynamic>> processed = [];

    for (var order in _recentActivity) {
      final orderName = order['orderName'] ?? 'Unknown Order';
      final orderUniqueId = order['orderUniqueId'] ?? '';
      final orderId = order['_id'] ?? '';
      final ops = order['operations'] as List? ?? [];
      final updatedAt = order['updatedAt'] ?? order['createdAt'];

      String displayId = orderUniqueId.length > 6
          ? orderUniqueId.substring(0, 6)
          : orderUniqueId;

      processed.add({
        "id": "${orderId}_movement",
        "type": "movement",
        "title": "Order #$displayId: $orderName",
        "subtitle": "Moved to ${name.value} department",
        "timeAgo": _calculateTimeAgo(updatedAt),
        "action": "MOVE",
        "orderId": orderId,
      });

      for (var op in ops) {
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

    // Sort by time
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
    String subtitle;

    switch (action) {
      case 'SUBMIT':
        type = 'submission';
        subtitle = "$checkpointName submitted for review";
        break;
      case 'APPROVE':
        type = 'approval';
        subtitle = "$checkpointName approved";
        break;
      case 'FINAL_APPROVE':
        type = 'approval';
        subtitle = "$checkpointName finalized";
        break;
      case 'REJECT':
        type = 'rejection';
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
}
