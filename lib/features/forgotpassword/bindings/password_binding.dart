import 'package:dariziflow_app/features/forgotpassword/controllers/password_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordController>(() => PasswordController());
  }
}