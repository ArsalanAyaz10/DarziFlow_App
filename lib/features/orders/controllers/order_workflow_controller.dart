import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class OrderWorkflowController extends GetxController {
  final OrderRepository repository;
  OrderWorkflowController(this.repository);

  final order = Rxn<OrderModel>();
  final isLoading = false.obs;
  final progress = 0.obs;
  final userRole = ''.obs;
  late String orderId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is OrderModel) {
      orderId = args.orderId;
      order.value = args;
      progress.value = args.progress.round();
    } else {
      orderId = (args is Map) ? args['orderId'].toString() : args.toString();
    }

    AppStorage.getUserRole().then((role) => userRole.value = role?.toUpperCase() ?? '');
    refreshOrderDetails();
  }

  Future<void> refreshOrderDetails() async {
    try {
      isLoading.value = true;
      if (orderId.isEmpty || orderId == "null") {
        isLoading.value = false;
        return;
      }

      final response = await repository.fetchOrderById(orderId);
      if (response != null) {
        final data = (response as Map<String, dynamic>).containsKey('order') 
            ? response['order'] as Map<String, dynamic> 
            : response;

        final newOrder = OrderModel.fromJson(data);
        order.value = newOrder;
        progress.value = newOrder.progress.round();
      }
    } catch (e) {
      dev.log("Error refreshing order workflow: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
