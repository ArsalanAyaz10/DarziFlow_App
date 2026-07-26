import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';

class OrderRequestService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final String _baseRoute = 'requests';

  /// Fetch all order requests
  Future<List<OrderRequestModel>> getAllRequests({Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _apiService.dio.get(_baseRoute, queryParameters: queryParameters);
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
        'contextType': context,
        'requestId': ?requestId,
      });
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to get upload signature');
    } catch (e) {
      rethrow;
    }
  }

  /// Upload a file to Cloudinary
  Future<Map<String, dynamic>> uploadToCloudinary({
    required String filePath,
    required String cloudName,
    required String apiKey,
    required String timestamp,
    required String signature,
    required String folder,
    String resourceType = 'auto',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
        'folder': folder,
      });

      // Create a fresh Dio instance for Cloudinary to avoid any interceptors from ApiService
      final response = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to upload to Cloudinary: $e");
    }
  }
}
