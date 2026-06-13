import 'package:dariziflow_app/features/QualityControl/service/qc_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class QcRepository {
  final QcService service;

  QcRepository(this.service);

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final data = await service.getStats();
      return data ?? {};
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching QC stats: $e");
      return {};
    }
  }

  Future<List<dynamic>> fetchPendingSubmissions() async {
    try {
      final data = await service.getPendingSubmissions();
      return data["data"] ?? [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching pending submissions: $e");
      return [];
    }
  }

  Future<bool> approveSubmission({
    required String orderId,
    required String opId,
    required String chkId,
  }) async {
    try {
      await service.approve(orderId: orderId, opId: opId, chkId: chkId);
      return true;
    } catch (e) {
      if (kDebugMode) dev.log("Error approving submission: $e");
      rethrow;
    }
  }

  Future<bool> rejectSubmission({
    required String orderId,
    required String opId,
    required String chkId,
    required String comment,
  }) async {
    try {
      await service.reject(orderId: orderId, opId: opId, chkId: chkId, comment: comment);
      return true;
    } catch (e) {
      if (kDebugMode) dev.log("Error rejecting submission: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> fetchQcHistory() async {
    try {
      final data = await service.getHistory();
      if (data != null && data['success'] == true) {
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      if (kDebugMode) dev.log("Error fetching QC history: $e");
      return [];
    }
  }
}
