import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/features/orders/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class OrderRepository {
  final OrderService service;
  final AppStorage storage = AppStorage();

  OrderRepository(this.service);

  Future<List<dynamic>> fetchActiveWorkflows(String id) async {
    try {
      final data = await service.getDepartmentOrders(id);

      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching active workflows: $e");
      return [];
    }
  }
}
