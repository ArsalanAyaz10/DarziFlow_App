import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/data/models/qc_history_model.dart';
import 'package:dariziflow_app/data/models/carousel_model.dart';
import 'package:dariziflow_app/data/services/api_service.dart';
import 'package:get/get.dart';

class ClientService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final String _baseRoute = 'client';

  /// Retrieves all carousel items for the client dashboard.
  Future<List<CarouselModel>> getCarouselItems() async {
    try {
      final response = await _apiService.dio.get('carousel');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data.map((item) => CarouselModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all orders associated with the logged-in client along with summary counts.
  Future<Map<String, dynamic>> getAllOrders() async {
    try {
      final response = await _apiService.dio.get('$_baseRoute/all-orders');
      if (response.statusCode == 200) {
        final List<dynamic> ordersData = response.data['orders'] ?? [];
        final orders = ordersData.map((item) => OrderModel.fromJson(item)).toList();
        return {
          'totalOrders': response.data['totalOrders'] ?? 0,
          'activeOrders': response.data['activeOrders'] ?? 0,
          'completedOrders': response.data['completedOrders'] ?? 0,
          'orders': orders,
        };
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      rethrow;
    }
  }

  /// Calculates and returns the percentage-based progress for a specific order.
  Future<Map<String, dynamic>> getOrderProgress(String orderId) async {
    try {
      final response = await _apiService.dio.get('$_baseRoute/order-progress/$orderId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to load order progress');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches the last 10 QC activities related to the client's orders.
  Future<List<QcHistoryModel>> getRecentHistory() async {
    try {
      final response = await _apiService.dio.get('$_baseRoute/getRecentHistory');
      if (response.statusCode == 200) {
        final List<dynamic> activitiesData = response.data['activities'] ?? [];
        return activitiesData.map((item) => QcHistoryModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
