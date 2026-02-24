import 'package:dariziflow_app/features/auth/bindings/login_binding.dart';
import 'package:dariziflow_app/features/auth/bindings/signup_binding.dart';
import 'package:dariziflow_app/features/auth/views/login_screen.dart';
import 'package:dariziflow_app/features/auth/views/signup_screen.dart';
import 'package:dariziflow_app/features/dept_head/bindings/DeptHeadBindings.dart';
import 'package:dariziflow_app/features/dept_head/views/dashboard_screen.dart';
import 'package:dariziflow_app/features/splash/bindings/splash_binding.dart';
import 'package:dariziflow_app/features/splash/views/splash_screen.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  static final INITIAL = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => SignupScreen(),
      binding: SignupBinding(),
    ),

    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: Routes.deptartmentHead,
      page: () => DeptHeadDashboardScreen(),
      binding: Deptheadbindings(),
    ),
  ];
}
