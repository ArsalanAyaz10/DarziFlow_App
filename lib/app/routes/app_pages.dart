import 'package:dariziflow_app/features/auth/bindings/login_binding.dart';
import 'package:dariziflow_app/features/auth/bindings/signup_binding.dart';
import 'package:dariziflow_app/features/auth/views/login_screen.dart';
import 'package:dariziflow_app/features/auth/views/signup_screen.dart';
import 'package:dariziflow_app/features/DepartmentHead/bindings/DeptHeadBindings.dart';
import 'package:dariziflow_app/features/DepartmentHead/views/all_activities_screen.dart';
import 'package:dariziflow_app/features/DepartmentHead/views/dashboard_screen.dart';
import 'package:dariziflow_app/features/ForgotPassword/bindings/password_binding.dart';
import 'package:dariziflow_app/features/ForgotPassword/views/forgotPassword_screen.dart';
import 'package:dariziflow_app/features/ForgotPassword/views/resetPassword_screen.dart';
import 'package:dariziflow_app/features/Orders/views/OrderWorkflow_screen.dart';
import 'package:dariziflow_app/features/Orders/views/order_detail_screen.dart';
import 'package:dariziflow_app/features/Orders/views/all_order_screen.dart';
import 'package:dariziflow_app/features/Orders/views/submitCheckpoint_screen.dart';
import 'package:dariziflow_app/features/Profile/bindings/editprofile_binding.dart';
import 'package:dariziflow_app/features/Profile/bindings/viewprofile_binding.dart';
import 'package:dariziflow_app/features/Profile/views/editprofile_screen.dart';
import 'package:dariziflow_app/features/Profile/views/viewprofile_screen.dart';
import 'package:dariziflow_app/features/Profile/bindings/profile_view_binding.dart';
import 'package:dariziflow_app/features/Profile/views/profile_view_screen.dart';
import 'package:dariziflow_app/features/Notifications/bindings/notification_binding.dart';
import 'package:dariziflow_app/features/Notifications/views/notification_inbox_screen.dart';
import 'package:dariziflow_app/features/Orders/bindings/order_binding.dart';
import 'package:dariziflow_app/features/Splash/views/splash_screen.dart';
import 'package:dariziflow_app/features/QualityControl/bindings/qc_dashboard_binding.dart';
import 'package:dariziflow_app/features/QualityControl/views/qc_dashboard_screen.dart';
import 'package:dariziflow_app/features/QualityControl/views/all_reviews_screen.dart';
import 'package:dariziflow_app/features/Splash/views/terms_of_service_screen.dart';
import 'package:dariziflow_app/features/Splash/views/privacy_policy_screen.dart';
import 'package:dariziflow_app/features/QualityControl/bindings/qc_history_binding.dart';
import 'package:dariziflow_app/features/QualityControl/views/qc_history_screen.dart';
import 'package:dariziflow_app/features/QualityControl/views/qc_history_detail_screen.dart';
import 'package:dariziflow_app/features/Client/bindings/client_dashboard_binding.dart';
import 'package:dariziflow_app/features/Client/views/client_dashboard_screen.dart';
import 'package:dariziflow_app/features/OrderRequest/bindings/order_request_binding.dart';
import 'package:dariziflow_app/features/OrderRequest/views/order_request_list_screen.dart';
import 'package:dariziflow_app/features/OrderRequest/views/create_order_request_screen.dart';
import 'package:dariziflow_app/features/Client/views/client_all_activities_screen.dart';
import 'package:dariziflow_app/features/Client/views/client_tracking_screen.dart';
import 'package:dariziflow_app/features/Client/bindings/client_tracking_binding.dart';
import 'package:dariziflow_app/features/Messages/bindings/chat_list_binding.dart';
import 'package:dariziflow_app/features/Messages/bindings/chat_room_binding.dart';
import 'package:dariziflow_app/features/Messages/views/messages_screen.dart';
import 'package:dariziflow_app/features/Messages/views/chat_room_screen.dart';
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
    GetPage(
      name: Routes.clientDashboard,
      page: () => const ClientDashboardScreen(),
      binding: ClientDashboardBinding(),
    ),
    GetPage(
      name: Routes.orderRequests,
      page: () => const OrderRequestListScreen(),
      binding: OrderRequestBinding(),
    ),
    GetPage(
      name: Routes.createOrderRequest,
      page: () => const CreateOrderRequestScreen(),
      binding: OrderRequestBinding(),
    ),
    GetPage(
      name: Routes.clientActivities,
      page: () => const ClientAllActivitiesScreen(),
      binding: ClientDashboardBinding(),
    ),
    GetPage(
      name: Routes.clientTracking,
      page: () => const ClientTrackingScreen(),
      binding: ClientTrackingBinding(),
    ),
    GetPage(
      name: Routes.messages,
      page: () => const ChatListScreen(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: Routes.chatRoom,
      page: () => const ChatRoomScreen(),
      binding: ChatRoomBinding(),
    ),
    GetPage(
      name: Routes.profileView,
      page: () => const ProfileViewScreen(),
      binding: ProfileViewBinding(),
    ),
  ];
}
