import 'package:dariziflow_app/core/network/api_client.dart';

class OrderService {
  final ApiClient apiClient;
  static final route = "orders";

  OrderService(this.apiClient);

  Future<dynamic> getOrderbyID(String orderID) async {
    await apiClient.get('/$route/$orderID');
  }

  Future<dynamic> getDepartmentOrders(String deptID) async {
    final response = await apiClient.get("/stats/$deptID/active-workflows");
    return response.data;
  }

}
