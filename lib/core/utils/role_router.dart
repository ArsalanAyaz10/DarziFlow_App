import 'package:get/get.dart';

class RoleRouter {
  static void route(String role) {
    switch (role.toUpperCase()) {
      case "DEPARTMENT_HEAD":
        Get.offAllNamed("/dept-head-dashboard");
        break;

      case "QC_MEMBER":
        Get.offAllNamed("/qc-dashboard");
        break;

      case "CLIENT":
        Get.offAllNamed("/client-dashboard");
        break;

      default:
        Get.offAllNamed("/login");
        Get.snackbar("Error", "Unauthorized role: $role");
    }
  }
}
