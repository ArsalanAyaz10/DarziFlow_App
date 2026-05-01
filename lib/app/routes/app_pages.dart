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
import 'package:dariziflow_app/features/orders/views/OrderWorkflow_screen.dart';
import 'package:dariziflow_app/features/orders/views/order_detail_screen.dart';
import 'package:dariziflow_app/features/orders/views/all_order_screen.dart';
import 'package:dariziflow_app/features/orders/views/submitCheckpoint_screen.dart';
import 'package:dariziflow_app/features/profile/bindings/editprofile_binding.dart';
import 'package:dariziflow_app/features/profile/bindings/viewprofile_binding.dart';
import 'package:dariziflow_app/features/profile/views/editprofile_screen.dart';
import 'package:dariziflow_app/features/profile/views/viewprofile_screen.dart';
import 'package:dariziflow_app/features/notifications/bindings/notification_binding.dart';
import 'package:dariziflow_app/features/notifications/views/notification_inbox_screen.dart';
import 'package:dariziflow_app/features/orders/bindings/order_binding.dart';
import 'package:dariziflow_app/features/splash/views/splash_screen.dart';
import 'package:dariziflow_app/features/qcDashboard/bindings/qc_dashboard_binding.dart';
import 'package:dariziflow_app/features/qcDashboard/views/qc_dashboard_screen.dart';
import 'package:dariziflow_app/features/qcDashboard/views/all_reviews_screen.dart';
import 'package:dariziflow_app/features/legal/views/terms_of_service_screen.dart';
import 'package:dariziflow_app/features/legal/views/privacy_policy_screen.dart';
import 'package:dariziflow_app/features/qcDashboard/bindings/qc_history_binding.dart';
import 'package:dariziflow_app/features/qcDashboard/views/qc_history_screen.dart';
import 'package:dariziflow_app/features/qcDashboard/views/qc_history_detail_screen.dart';
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
      name: Routes.qcDashboard,
      page: () => const QCDashboardScreen(),
      binding: QcDashboardBinding(),
    ),
    GetPage(
      name: Routes.allReviews,
      page: () => const AllReviewsScreen(),
      binding: QcDashboardBinding(),
    ),
    GetPage(
      name: Routes.qcHistory,
      page: () => const QcHistoryScreen(),
      binding: QcHistoryBinding(),
    ),
    GetPage(
      name: Routes.qcHistoryDetail,
      page: () => const QcHistoryDetailScreen(),
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
      name: Routes.orders,
      page: () => const AllOrderScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: Routes.orderDetails,
      page: () => OrderDetailScreen(),
      bindings: [OrderBinding(), QcDashboardBinding()],
    ),
    GetPage(
      name: Routes.workflow,
      page: () => OrderWorkflowScreen(),
      bindings: [OrderBinding(), QcDashboardBinding()],
    ),

    GetPage(
      bindings: [OrderBinding(), QcDashboardBinding()],
      name: Routes.submitCheckpoint,
      page: () => const SubmitcheckpointScreen(),
    ),
    GetPage(
      name: '/notification-inbox',
      page: () => const NotificationInboxScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.termsOfService,
      page: () => const TermsOfServiceScreen(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
    ),
  ];
}
