import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/features/orders/services/order_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class OrderRepository {
  final OrderService service;
  final AppStorage storage = AppStorage();

  OrderRepository(this.service);

  Future<dynamic> fetchOrderById(String orderID) async {
    try {
      final response = await service.getOrderbyID(orderID);
      if (response != null && response.statusCode == 200) {
        return response.data;
      } else {
        if (kDebugMode) {
          dev.log("Failed to fetch order. Status: ${response?.statusCode}");
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching order by ID ($orderID): $e");
      return null;
    }
  }

  Future<List<dynamic>> fetchActiveWorkflows(String id) async {
    try {
      final data = await service.getDepartmentOrders(id);

      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching active workflows: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchGlobalActiveWorkflows() async {
    try {
      final data = await service.getGlobalActiveWorkflows();
      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching global active workflows: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchAllOrders() async {
    try {
      final data = await service.getAllOrders();
      // If the response is a direct list, return it. If it's a map with "orders" key, return that.
      if (data is List) return data;
      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching all orders: $e");
      return [];
    }
  }

  Future<List<dynamic>> fetchAllWorkflows(String id) async {
    try {
      final data = await service.getAllDepartmentOrders(id);

      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching all workflows: $e");
      return [];
    }
  }

  Future<bool> submitCheckpointData({
    required String orderId,
    required String opId,
    required String chkId,
    required String remarks,
    required List<Map<String, dynamic>> evidence, // List of SubmissionFile maps
  }) async {
    try {
      await service.submitCheckpoint(
        orderId: orderId,
        opId: opId,
        chkId: chkId,
        data: {"submissionText": remarks, "files": evidence},
      );
      return true;
    } catch (e) {
      dev.log("Repo Error submitting checkpoint: $e");
      return false;
    }
  }
}
