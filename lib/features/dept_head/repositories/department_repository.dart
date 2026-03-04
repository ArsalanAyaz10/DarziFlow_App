import 'package:dariziflow_app/features/dept_head/service/department_service.dart';

class DepartmentRepository {
  final DepartmentService service;

  DepartmentRepository(this.service);

  Future<List<dynamic>> fetchDepartments() async {
    final data = await service.getDepartments();
    return data["departments"] ?? [];
  }

  Future<Map<String, dynamic>> fetchDepartmentById(String id) async {
    final data = await service.getDepartmentById(id);
    return data["department"];
  }

  // This fetches both Dept metadata AND the efficiency/chart stats
  Future<Map<String, dynamic>> fetchOverview() async {
    final data = await service.getDepartmentOverview();
    return data;
  }

  // Fetches live workflows/recent activity
  Future<List<dynamic>> fetchActiveWorkflows(String id) async {
    final data = await service.getDepartmentActiveWorkflows(id);
    return data["orders"] ?? [];
  }
}
