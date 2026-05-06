import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/DepartmentHead/repositories/department_repository.dart';
import 'package:dariziflow_app/features/DepartmentHead/service/department_service.dart';
import 'package:dariziflow_app/features/Orders/controllers/checkpoint_controller.dart';
import 'package:dariziflow_app/features/Orders/controllers/orderDetail_controller.dart';
import 'package:dariziflow_app/features/Orders/controllers/order_controller.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:dariziflow_app/features/Orders/services/order_service.dart';
import 'package:get/get.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DepartmentService(Get.find()));
    Get.lazyPut(() => DepartmentRepository(Get.find()));
    Get.lazyPut(() => UploadService(Get.find()));
    Get.lazyPut(() => OrderService(Get.find()));
    Get.lazyPut(() => OrderRepository(Get.find()));
    Get.lazyPut(() => OrderController(Get.find()));
    Get.lazyPut(() => OrderDetailController(Get.find()));
    Get.lazyPut(
      () => CheckpointController(
        Get.find<OrderRepository>(),
        Get.find<UploadService>(),
        Get.find<OrderDetailController>(),
      ),
    );
  }
}
