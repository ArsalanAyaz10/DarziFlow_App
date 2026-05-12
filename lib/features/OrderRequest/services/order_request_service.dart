import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

class OrderRequestService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final String _baseRoute = 'requests';

  /// Fetch all order requests
  Future<List<OrderRequestModel>> getAllRequests() async {
    try {
      final response = await _apiService.dio.get(_baseRoute);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => OrderRequestModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single request by ID
  Future<OrderRequestModel?> getRequestById(String id) async {
    try {
      final response = await _apiService.dio.get('$_baseRoute/$id');
      if (response.statusCode == 200) {
        return OrderRequestModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new order request (Initial Ask)
  Future<OrderRequestModel> createRequest(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post(_baseRoute, data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderRequestModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create order request');
    } catch (e) {
      rethrow;
    }
  }

  /// Submit a new proposal (Negotiation)
  Future<OrderRequestModel> addProposal(String requestId, Map<String, dynamic> proposalData) async {
    try {
      final response = await _apiService.dio.post(
        '$_baseRoute/$requestId/proposals',
        data: proposalData,
      );
      if (response.statusCode == 200) {
        return OrderRequestModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to submit proposal');
    } catch (e) {
      rethrow;
    }
  }

  /// Convert a request to an active Order (Admin only)
  Future<dynamic> convertRequest(String requestId) async {
    try {
      final response = await _apiService.dio.post('$_baseRoute/$requestId/convert');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['data']; // Returns the created Order
      }
      throw Exception('Failed to convert request to order');
    } catch (e) {
      rethrow;
    }
  }

  /// Get Cloudinary upload signature
  Future<Map<String, dynamic>> getUploadSignature({
    required String context,
    String? requestId,
  }) async {
    try {
      final response = await _apiService.dio.post('upload/signature', data: {
        'context': context,
        if (requestId != null) 'requestId': requestId,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get upload signature');
    } catch (e) {
      rethrow;
    }
  }
}
