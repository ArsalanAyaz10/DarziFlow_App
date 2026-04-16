import 'package:dariziflow_app/features/auth/bindings/login_binding.dart';
import 'package:dariziflow_app/features/auth/bindings/signup_binding.dart';
import 'package:dariziflow_app/features/auth/views/login_screen.dart';
import 'package:dariziflow_app/features/auth/views/signup_screen.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/bindings/DeptHeadBindings.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/views/all_activities_screen.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/views/dashboard_screen.dart';
import 'package:dariziflow_app/features/forgotpassword/bindings/password_binding.dart';
import 'package:dariziflow_app/features/forgotpassword/views/forgotPassword_screen.dart';
import 'package:dariziflow_app/features/forgotpassword/views/resetPassword_screen.dart';
import 'package:dariziflow_app/features/orders/bindings/all_orders_binding.dart';
import 'package:dariziflow_app/features/orders/views/OrderWorkflow_screen.dart';
import 'package:dariziflow_app/features/orders/views/all_orders_screen.dart';
import 'package:dariziflow_app/features/orders/views/order_detail_screen.dart';
import 'package:dariziflow_app/features/orders/views/order_screen.dart';
import 'package:dariziflow_app/features/orders/views/submitCheckpoint_screen.dart';
import 'package:dariziflow_app/features/profile/bindings/editprofile_binding.dart';
import 'package:dariziflow_app/features/profile/bindings/viewprofile_binding.dart';
import 'package:dariziflow_app/features/profile/views/editprofile_screen.dart';
import 'package:dariziflow_app/features/profile/views/viewprofile_screen.dart';
import 'package:dariziflow_app/features/orders/bindings/order_binding.dart';
import 'package:dariziflow_app/features/splash/views/splash_screen.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  static final initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => SplashScreen()),
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
      name: '/forgot-password',
      page: () => const ForgotpasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.deptartmentHead,
      page: () => DeptHeadDashboardScreen(),
      binding: DeptheadBindings(),
    ),
    GetPage(
      name: Routes.resetpassword,
      page: () => const ResetPasswordView(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: Routes.profile,
      page: () => const ViewProfileScreen(),
      binding: ViewProfileBinding(),
    ),

    GetPage(
      name: '/editprofile',
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
    ),

    GetPage(name: '/all-activities', page: () => const AllActivitiesScreen()),
    GetPage(
      name: Routes.allOrders,
      page: () => const AllOrdersScreen(),
      binding: AllOrdersBinding(),
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrderScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => OrderDetailScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.workflow,
      page: () => OrderWorkflowScreen(),
      binding: OrderBinding(),
    ),

    GetPage(
      binding: OrderBinding(),
      name: Routes.submitCheckpoint,
      page: () => const SubmitcheckpointScreen(),
    ),
  ];
}
