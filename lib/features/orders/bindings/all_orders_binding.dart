import 'package:dariziflow_app/features/orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/orders/services/order_service.dart';
import 'package:get/get.dart';

class AllOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OrderService(Get.find()));
    Get.lazyPut(() => OrderRepository(Get.find()));
  }
}
