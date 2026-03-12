import 'package:dariziflow_app/features/auth/controllers/emailVerify_controller.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get.dart';

class EmailverifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailverifyController>(
      () => EmailverifyController(Get.find<AuthRepository>()),
    );
  }
}