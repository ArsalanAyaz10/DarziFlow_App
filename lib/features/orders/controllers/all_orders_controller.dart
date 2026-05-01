import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllOrdersController extends GetxController {
  final OrderRepository repository;

  AllOrdersController(this.repository);

  var orders = <OrderModel>[].obs;

  var isLoading = false.obs;
  var errorMessage = ''.obs;

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

  Future<void> fetchOrders() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await AppStorage.getAuthUser();
      final deptId = user?.department;

      if (deptId == null) {
        errorMessage.value = "Department not found.";
        return;
      }

      final response = await repository.fetchAllWorkflows(deptId);
      orders.value = (response).map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      errorMessage.value = "Failed to load orders.";
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchBar(String query) => searchQuery.value = query;

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<OrderModel> get filteredOrders {
    var list = [...orders];

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((o) => 
        o.orderName.toLowerCase().contains(q) ||
        o.uniqueId.toLowerCase().contains(q) ||
        o.orderId.toLowerCase().contains(q)
      ).toList();
    }

    if (selectedFilter.value == 'Active') {
      return list.where((o) => o.progress < 100).toList();
    } else if (selectedFilter.value == 'Completed') {
      return list.where((o) => o.progress >= 100).toList();
    }
    
    return list;
  }
}
