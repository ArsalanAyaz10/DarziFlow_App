import 'package:dariziflow_app/core/network/api_client.dart';

class OrderService {
  final ApiClient apiClient;
  static final route = "orders";

  OrderService(this.apiClient);

  Future<dynamic> getOrderbyID(String orderID) async {
    return await apiClient.get('/$route/$orderID');
  }

  Future<dynamic> getAllOrders() async {
    final response = await apiClient.get('/$route/');
    return response.data;
  }

  Future<dynamic> getDepartmentOrders(String deptID) async {
    final response = await apiClient.get("/stats/$deptID/active-workflows");
    return response.data;
  }

  Future<dynamic> getAllDepartmentOrders(String deptID) async {
    final response = await apiClient.get("/stats/$deptID/all-workflows");
    return response.data;
  }

  Future<dynamic> getGlobalActiveWorkflows() async {
    final response = await apiClient.get("/stats/active-workflows");
    return response.data;
  }

  Future<dynamic> submitCheckpoint({
    required String orderId,
    required String opId,
    required String chkId,
    required Map<String, dynamic> data,
  }) async {
    // route = /orders/:orderId/workflow/:opId/checkpoints/:chkId/submit
    final response = await apiClient.post(
      '/$route/$orderId/workflow/$opId/checkpoints/$chkId/submit',
      data: data,
    );
    return response.data;
  }
}
