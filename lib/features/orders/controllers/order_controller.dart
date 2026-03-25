import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/order_card_model.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class OrderController extends GetxController {
  final OrderRepository repository;

  OrderController(this.repository);

  var orders = <OrderCardModel>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filter state
  var selectedFilter = 'All'.obs;
  final List<String> filterOptions = ['All', 'Active', 'Completed', 'Overdue'];
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    searchController.dispose(); // Always dispose controllers
    super.onClose();
  }

  Future<String?> _getDepartmentId() async {
    try {
      // Extract Dept ID from Storage
      final user = await AppStorage.getUser();
      if (user != null && user['department'] != null) {
        return user['department'].toString();
      }
      return null;
    } catch (e) {
      if (kDebugMode) dev.log("Error getting department ID: $e");
      return null;
    }
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final deptId = await _getDepartmentId();

      if (deptId == null || deptId.isEmpty) {
        errorMessage.value =
            "Department ID not found. Please check your profile.";
        isLoading.value = false;
        if (kDebugMode) dev.log("Department ID is null or empty");
        return;
      }

      if (kDebugMode) dev.log("Fetching orders for department: $deptId");

      final ordersData = await repository.fetchActiveWorkflows(deptId);

      // Transform API response into OrderCardModel
      orders.value = ordersData.map((orderData) {
        return _transformToOrderCard(orderData);
      }).toList();

      if (kDebugMode) dev.log("Fetched ${orders.length} orders");
    } catch (e) {
      errorMessage.value = "Failed to load orders. Please try again.";
      if (kDebugMode) dev.log("Error fetching orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  OrderCardModel _transformToOrderCard(Map<String, dynamic> orderData) {
    final orderId = orderData['_id']?.toString() ?? '';

    final orderName = orderData['orderName'] ?? 'Unknown Order';
    final uniqueId = orderData['orderUniqueId']?.toString() ?? '';
    final dueDate = orderData['dueDate'] != null
        ? DateTime.tryParse(orderData['dueDate'].toString())
        : null;

    // Calculate progress and status
    final progress = _calculateProgress(orderData);
    final status = _determineStatus(orderData, progress, dueDate);

    return OrderCardModel(
      orderId: orderId,
      orderName: orderName,
      uniqueId: uniqueId,
      dueDate: dueDate,
      status: status,
      progress: progress,
      rawData: orderData,
    );
  }

  int _calculateProgress(Map<String, dynamic> orderData) {
    int totalCheckpoints = 0;
    int completedCheckpoints = 0;

    final operations = orderData['operations'] as List? ?? [];

    for (var op in operations) {
      final checkpoints = op['checkpoints'] as List? ?? [];
      totalCheckpoints += checkpoints.length;

      for (var cp in checkpoints) {
        final status = cp['status'] ?? '';
        if (status == 'COMPLETED' ||
            status == 'QC_APPROVED' ||
            status == 'APPROVED') {
          completedCheckpoints++;
        }
      }
    }

    if (totalCheckpoints == 0) return 0;
    return ((completedCheckpoints / totalCheckpoints) * 100).round();
  }

  OrderStatus _determineStatus(
    Map<String, dynamic> orderData,
    int progress,
    DateTime? dueDate,
  ) {
    // Check for overdue first
    if (dueDate != null && dueDate.isBefore(DateTime.now()) && progress < 100) {
      return OrderStatus.OVERDUE;
    }

    // Check for high priority (based on due date proximity)
    if (dueDate != null) {
      final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
      if (daysUntilDue <= 2 && progress < 100) {
        return OrderStatus.HIGH_PRIORITY;
      }
    }

    // Check operation statuses for rejection
    final operations = orderData['operations'] as List? ?? [];
    for (var op in operations) {
      final checkpoints = op['checkpoints'] as List? ?? [];
      for (var cp in checkpoints) {
        if (cp['status'] == 'REJECTED' || cp['status'] == 'QC_REJECTED') {
          return OrderStatus.NEEDS_ATTENTION;
        }
      }
    }

    // Progress-based status
    if (progress == 0) return OrderStatus.PENDING;
    if (progress == 100) return OrderStatus.COMPLETED;
    return OrderStatus.IN_PROGRESS;
  }

  // Filter and search getters
  List<OrderCardModel> get filteredOrders {
    // First apply status filter
    var filtered = _applyStatusFilter();

    // Then apply search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((order) {
        final query = searchQuery.value.toLowerCase();
        return order.orderName.toLowerCase().contains(query) ||
            order.displayOrderId.toLowerCase().contains(query) ||
            order.uniqueId.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  List<OrderCardModel> _applyStatusFilter() {
    switch (selectedFilter.value) {
      case 'Active':
        return orders
            .where(
              (o) =>
                  o.status == OrderStatus.IN_PROGRESS ||
                  o.status == OrderStatus.HIGH_PRIORITY ||
                  o.status == OrderStatus.NEEDS_ATTENTION,
            )
            .toList();
      case 'Completed':
        return orders.where((o) => o.status == OrderStatus.COMPLETED).toList();
      case 'Overdue':
        return orders.where((o) => o.status == OrderStatus.OVERDUE).toList();
      default:
        return orders.toList();
    }
  }

  // Statistics getters
  int get totalOrders => orders.length;

  int get activeCount => orders
      .where(
        (o) =>
            o.status == OrderStatus.IN_PROGRESS ||
            o.status == OrderStatus.HIGH_PRIORITY ||
            o.status == OrderStatus.NEEDS_ATTENTION,
      )
      .length;

  int get completedCount =>
      orders.where((o) => o.status == OrderStatus.COMPLETED).length;

  int get overdueCount =>
      orders.where((o) => o.status == OrderStatus.OVERDUE).length;

  int get pendingCount =>
      orders.where((o) => o.status == OrderStatus.PENDING).length;

  // Search methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  // Filter methods
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Refresh method
  Future<void> refreshOrders() async {
    await fetchOrders();
  }
}
