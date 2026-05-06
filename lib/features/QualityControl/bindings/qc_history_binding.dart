import 'package:dariziflow_app/features/QualityControl/repositories/qc_repository.dart';
import 'package:dariziflow_app/features/QualityControl/service/qc_service.dart';
import 'package:dariziflow_app/features/QualityControl/controllers/qc_history_controller.dart';
import 'package:get/get.dart';

class QcHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QcService(apiClient: Get.find()));
    Get.lazyPut(() => QcRepository(Get.find()));
    Get.lazyPut<QcHistoryController>(
      () => QcHistoryController(repository: Get.find()),
    );
  }
}
