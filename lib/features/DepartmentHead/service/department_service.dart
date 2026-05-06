import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import 'dart:developer' as dev;


class DepartmentService {
  final ApiClient apiClient;
  static final route = "departments";
  DepartmentService(this.apiClient);

  Future<dynamic> getDepartments() async {
    final response = await apiClient.get("/departments");
    return response.data;
  }

  Future<dynamic> getDepartmentById(String deptId) async {
    final response = await apiClient.get("/$route/$deptId");
    return response.data;
  }

  Future<dynamic> getDepartmentOverview() async {
    final response = await apiClient.get("/$route/overview");
    return response.data;
  }

  Future<dynamic> getDepartmentActiveWorkflows(String deptId) async {
    final response = await apiClient.get("/stats/$deptId/active-workflows");
    return response.data;
  }

  Future<Map<String, dynamic>> getTemplateStats(String deptId) async {
    try {
      final overview = await getDepartmentOverview();
      return overview['templateStats'] ??
          {'totalOperations': 0, 'totalCheckpoints': 0};
    } catch (e) {
      if (kDebugMode) dev.log("Error in getTemplateStats: $e");
      return {'totalOperations': 0, 'totalCheckpoints': 0};
    }
  }

  Future<Map<String, dynamic>> getOrderStats(String deptId) async {
    try {
      final overview = await getDepartmentOverview();
      return overview['orderStats'] ??
          {'totalOrders': 0, 'inProgress': 0, 'pending': 0, 'completed': 0};
    } catch (e) {
      if (kDebugMode) dev.log("Error in getOrderStats: $e");
      return {'totalOrders': 0, 'inProgress': 0, 'pending': 0, 'completed': 0};
    }
  }

  Future<Map<String, dynamic>> getOperationStats(String deptId) async {
    try {
      final overview = await getDepartmentOverview();
      return overview['operationStats'] ??
          {
            'totalOperationsHandled': 0,
            'completed': 0,
            'pending': 0,
            'inProgress': 0,
            'rejected': 0,
          };
    } catch (e) {
      if (kDebugMode) dev.log("Error in getOperationStats: $e");
      return {
        'totalOperationsHandled': 0,
        'completed': 0,
        'pending': 0,
        'inProgress': 0,
        'rejected': 0,
      };
    }
  }
}
