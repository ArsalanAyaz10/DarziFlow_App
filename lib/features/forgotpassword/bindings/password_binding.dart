import 'package:dariziflow_app/features/forgotpassword/controllers/password_controller.dart';
import 'package:dariziflow_app/features/forgotpassword/controllers/resetpassword_controller.dart';
import 'package:dariziflow_app/features/forgotpassword/repositories/password_repository.dart';
import 'package:dariziflow_app/features/forgotpassword/services/password_service.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordService(Get.find()));
    Get.lazyPut(() => ForgotPasswordService(Get.find()));
    Get.lazyPut<ForgotPasswordRepository>(
      () => ForgotPasswordRepository(Get.find()),
    );
    Get.lazyPut<PasswordController>(
      () =>
          PasswordController(repository: Get.find<ForgotPasswordRepository>()),
    );
    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(Get.find<ForgotPasswordRepository>()),
    );

    
  }
}
