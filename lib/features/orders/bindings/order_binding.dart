import 'package:dariziflow_app/features/orders/controllers/order_controller.dart';
import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/orders/services/order_service.dart';
import 'package:get/get.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderService(Get.find()));
    Get.lazyPut(() => OrderRepository(Get.find()));
    Get.lazyPut(() => OrderController(Get.find()));
  }
}
