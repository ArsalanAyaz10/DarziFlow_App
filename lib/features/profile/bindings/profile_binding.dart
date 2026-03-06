import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:dariziflow_app/features/profile/controllers/viewProfile_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewprofileController(Get.find<AuthRepository>()));
  }
}
