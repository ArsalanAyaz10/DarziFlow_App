import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/Orders/services/order_service.dart';
import 'package:dariziflow_app/features/QualityControl/service/qc_service.dart';
import 'package:dariziflow_app/features/QualityControl/repositories/qc_repository.dart';
import 'package:dariziflow_app/features/QualityControl/controllers/qc_dashboard_controller.dart';
import 'package:get/get.dart';

class QcDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QcService(apiClient: Get.find()));
    Get.lazyPut(() => QcRepository(Get.find()));
    Get.lazyPut(() => OrderService(Get.find()));
    Get.lazyPut(() => OrderRepository(Get.find()));
    Get.lazyPut<QcDashboardController>(
      () => QcDashboardController(
        repository: Get.find(),
        orderRepository: Get.find(),
      ),
    );
  }
}
