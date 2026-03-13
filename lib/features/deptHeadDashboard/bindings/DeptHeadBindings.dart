import 'package:dariziflow_app/features/deptHeadDashboard/service/department_service.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/repositories/department_repository.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class DeptheadBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DepartmentRepository(Get.find()));
    Get.lazyPut<DeptHeadController>(
      () => DeptHeadController(repository: Get.find()),
    );
    Get.lazyPut(() => DepartmentService(Get.find()));
  }
}
