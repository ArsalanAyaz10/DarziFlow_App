import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class OrderController extends GetxController {
  final OrderRepository repository;

  OrderController(this.repository);

  var orders = <OrderModel>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var userRole = ''.obs;

  var selectedFilter = 'All'.obs;
  final List<String> filterOptions = ['All', 'Active', 'Completed'];

  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is List) {
      loadArguments(Get.arguments as List);
    } else {
      fetchOrders();
    }
  }

  void loadArguments(List rawData) async {
    try {
      final role = await AppStorage.getUserRole() ?? "";
      userRole.value = role.toUpperCase();

      orders.value = rawData.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      fetchOrders();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<String?> getDepartmentId() async {
    try {
      final user = await AppStorage.getAuthUser();
      return user?.department;
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

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final role = await AppStorage.getUserRole() ?? "";
      userRole.value = role.toUpperCase();
      final isQC = userRole.value == "QC_MEMBER";

      List data;
      if (isQC) {
        data = await repository.fetchAllOrders();
      } else {
        final deptId = await getDepartmentId();
        if (deptId == null) {
          errorMessage.value = "Department not found.";
          return;
        }
        data = await repository.fetchActiveWorkflows(deptId);
      }

      orders.value = data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = "Failed to load orders.";
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderModel> get filteredOrders {
    var list = orders;

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
