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
