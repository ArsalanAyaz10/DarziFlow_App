import '../../../core/network/api_client.dart';

class DepartmentService {
  final ApiClient apiClient;

  DepartmentService(this.apiClient);

  Future<dynamic> getDepartments() async {
    final response = await apiClient.get("/departments");
    return response.data;
  }

  Future<dynamic> getDepartmentById(String deptId) async {
    final response = await apiClient.get("/departments/$deptId");
    return response.data;
  }

  Future<dynamic> getDepartmentOverview() async {
    final response = await apiClient.get("/departments/overview");
    return response.data;
  }

  Future<dynamic> getDepartmentActiveWorkflows(String deptId) async {
    final response = await apiClient.get("/stats/$deptId/active-workflows");
    return response.data;
  }
}
