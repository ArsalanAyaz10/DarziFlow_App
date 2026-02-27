import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SplashController extends GetxController {
  final AuthRepository repo;

  SplashController(this.repo);

}
