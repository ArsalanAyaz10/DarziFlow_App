import 'package:dariziflow_app/features/qcDashboard/service/qc_service.dart';
import 'package:dariziflow_app/features/qcDashboard/repositories/qc_repository.dart';
import 'package:dariziflow_app/features/qcDashboard/controllers/qc_dashboard_controller.dart';
import 'package:get/get.dart';

class QcDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QcService(apiClient: Get.find()));
    Get.lazyPut(() => QcRepository(Get.find()));
    Get.lazyPut<QcDashboardController>(
      () => QcDashboardController(repository: Get.find()),
    );
  }
}
