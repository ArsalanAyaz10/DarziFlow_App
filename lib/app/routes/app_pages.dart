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
  ];
}
