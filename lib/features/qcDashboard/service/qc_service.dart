import 'package:dariziflow_app/core/network/api_client.dart';

class QcService {
  final ApiClient apiClient;
  static const route = "/stats";

  QcService({required this.apiClient});

  Future<dynamic> getStats() async {
    final response = await apiClient.get("$route/getStats");
    return response.data;
  }

  Future<dynamic> getPendingSubmissions() async {
    final response = await apiClient.get("$route/submissions/pending");
    return response.data;
  }

  Future<dynamic> getRejectionReasons() async {
    final response = await apiClient.get("$route/rejection-reasons");
    return response.data;
  }

  Future<dynamic> approve({
    required String orderId,
    required String opId,
    required String chkId,
  }) async {
    final response = await apiClient.patch(
      "/orders/$orderId/workflow/$opId/checkpoints/$chkId/approve",
    );
    return response.data;
  }

  Future<dynamic> reject({
    required String orderId,
    required String opId,
    required String chkId,
    required String comment,
  }) async {
    final response = await apiClient.patch(
      "/orders/$orderId/workflow/$opId/checkpoints/$chkId/reject",
      data: {"comment": comment},
    );
    return response.data;
  }
}
