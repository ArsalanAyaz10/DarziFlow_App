import 'package:dariziflow_app/features/auth/controllers/signup_controller.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(
      () => SignupController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
