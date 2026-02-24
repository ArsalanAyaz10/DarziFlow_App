import 'package:dariziflow_app/features/auth/controllers/login_controller.dart';
import 'package:get/get.dart';
import '../controllers/signup_controller.dart';
import '../repositories/auth_repository.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find<AuthRepository>()),
    );
  }
}
