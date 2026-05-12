import 'package:dariziflow_app/features/OrderRequest/controllers/order_request_controller.dart';
import 'package:dariziflow_app/features/OrderRequest/services/order_request_service.dart';
import 'package:get/get.dart';

class OrderRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRequestService>(() => OrderRequestService());
    Get.lazyPut<OrderRequestController>(() => OrderRequestController());
  }
}
