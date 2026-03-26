import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart'
    show CheckpointModel;
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderController extends GetxController {
  final OrderRepository repository;

  OrderController(this.repository);

  var orders = <OrderCardModel>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // UI state only
  var selectedFilter = 'All'.obs;
  final List<String> filterOptions = ['All', 'Active', 'Completed'];

  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<String?> _getDepartmentId() async {
    try {
      final user = await AppStorage.getUser();
      return user?['department']?.toString();
    } catch (e) {
      return null;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  int _calculateProgress(Map<String, dynamic> data) {
    int total = 0;
    int done = 0;

    final operations = data['operations'] as List? ?? [];

    for (final op in operations) {
      final checkpoints = op['checkpoints'] as List? ?? [];
      total += checkpoints.length;

      for (final cp in checkpoints) {
        final status = cp['status'];

        if (status == 'COMPLETED' ||
            status == 'QC_APPROVED' ||
            status == 'APPROVED') {
          done++;
        }
      }
    }

    if (total == 0) return 0;
    return ((done / total) * 100).round();
  }

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final deptId = await _getDepartmentId();

      if (deptId == null) {
        errorMessage.value = "Department not found.";
        return;
      }

      final response = await repository.fetchActiveWorkflows(deptId);

      final List data = response;

      orders.value = data.map((json) => _mapOrder(json)).toList();
    } catch (e) {
      errorMessage.value = "Failed to load orders.";
    } finally {
      isLoading.value = false;
    }
  }

  OrderCardModel _mapOrder(Map<String, dynamic> json) {
    // 1. Calculate the progress locally using your logic
    final calculatedProgress = _calculateProgress(json).toDouble();

    return OrderCardModel(
      orderId: json['_id'] ?? '',
      orderName: json['orderName'] ?? 'Unknown Order',
      uniqueId: json['orderUniqueId'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,

      // 2. Use the calculated progress instead of the backend's 0
      progress: calculatedProgress,

      operations: (json['operations'] as List? ?? [])
          .map(
            (op) => OperationModel(
              name: op['name'] ?? '',
              status: op['status'] ?? 'PENDING',
              checkpoints: (op['checkpoints'] as List? ?? [])
                  .map(
                    (cp) => CheckpointModel(
                      name: cp['name'] ?? '',
                      status: cp['status'] ?? 'PENDING',
                      qcRequired: cp['qcRequired'] ?? false,
                      submissionFiles: [],
                      history: [],
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  List<OrderCardModel> get filteredOrders {
    var list = orders;

    // FILTER: SEARCH
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((o) {
            return o.orderName.toLowerCase().contains(q) ||
                o.uniqueId.toLowerCase().contains(q) ||
                o.orderId.toLowerCase().contains(q);
          })
          .toList()
          .obs;
    }

    // FILTER: STATUS (derived ONLY from progress)
    switch (selectedFilter.value) {
      case 'Active':
        return list.where((o) => o.progress < 100).toList();
      case 'Completed':
        return list.where((o) => o.progress >= 100).toList();
      default:
        return list;
    }
  }
}
