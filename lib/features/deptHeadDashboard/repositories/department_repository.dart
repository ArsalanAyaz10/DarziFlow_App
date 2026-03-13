import 'package:dariziflow_app/features/deptHeadDashboard/service/department_service.dart';
import 'package:flutter/foundation.dart';

class DepartmentRepository {
  final DepartmentService service;

  DepartmentRepository(this.service);

  Future<List<dynamic>> fetchDepartments() async {
    try {
      final data = await service.getDepartments();
      return data["departments"] ?? [];
    } catch (e) {
      if (kDebugMode) print("Error fetching departments: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchDepartmentById(String id) async {
    try {
      final data = await service.getDepartmentById(id);
      return data["department"] ?? {};
    } catch (e) {
      if (kDebugMode) print("Error fetching department by id: $e");
      return {};
    }
  }

   Future<Map<String, dynamic>> fetchOverview() async {
    try {
      final data = await service.getDepartmentOverview();
      return data;
    } catch (e) {
      if (kDebugMode) print("Error fetching overview: $e");
      return {};
    }
  }

  Future<List<dynamic>> fetchActiveWorkflows(String id) async {
    try {
      final data = await service.getDepartmentActiveWorkflows(id);
      return data["orders"] ?? [];
    } catch (e) {
      if (kDebugMode) print("Error fetching active workflows: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchTemplateStats(String deptId) async {
    try {
      final data = await service.getTemplateStats(deptId);
      return data;
    } catch (e) {
      if (kDebugMode) print("Error fetching template stats: $e");
      return {'totalOperations': 0, 'totalCheckpoints': 0};
    }
  }

  Future<Map<String, dynamic>> fetchOrderStats(String deptId) async {
    try {
      final data = await service.getOrderStats(deptId);
      return data;
    } catch (e) {
      if (kDebugMode) print("Error fetching order stats: $e");
      return {'totalOrders': 0, 'inProgress': 0, 'pending': 0, 'completed': 0};
    }
  }

  Future<Map<String, dynamic>> fetchOperationStats(String deptId) async {
    try {
      final data = await service.getOperationStats(deptId);
      return data;
    } catch (e) {
      if (kDebugMode) print("Error fetching operation stats: $e");
      return {
        'totalOperationsHandled': 0,
        'completed': 0,
        'pending': 0,
        'inProgress': 0,
        'rejected': 0,
      };
    }
  }

  Future<Map<String, dynamic>> fetchDepartmentTemplate(String deptId) async {
    try {
      final data = await service.getDepartmentById(deptId);
      return data["department"] ?? {};
    } catch (e) {
      if (kDebugMode) print("Error fetching department template: $e");
      return {};
    }
  }
}
