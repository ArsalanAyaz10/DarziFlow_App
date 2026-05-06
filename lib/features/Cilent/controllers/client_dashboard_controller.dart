import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:get/get.dart';

class ClientDashboardController extends GetxController {
  final userName = "".obs;
  final userAvatar = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AppStorage.getAuthUser();
    if (user != null) {
      userName.value = user.name;
      userAvatar.value = user.avatarUrl;
    }
  }

  final activeOrdersCount = 8.obs;
  RxBool isLoading = false.obs;
  final completedOrdersCount = 15.obs;
  final totalSpent = 12450.0.obs;

  final recentOrders = <Map<String, dynamic>>[
    {
      "id": "#DF-9012",
      "name": "Navy Blue Tuxedo",
      "status": "In Production",
      "image": "assets/images/navy_suit_1777995278931.png",
      "progress": 65,
      "milestone": "Cutting Phase",
      "timeline": [
        {"title": "Order Placed", "time": "10:00 AM", "completed": true},
        {"title": "Fabric Sourced", "time": "02:00 PM", "completed": true},
        {"title": "Cutting Phase", "time": "In Progress", "completed": false},
        {"title": "Stitching", "time": "Pending", "completed": false},
      ],
    },
    {
      "id": "#DF-8845",
      "name": "Grey Slim Fit Suit",
      "status": "Ready for Pickup",
      "image": "assets/images/grey_suit_1777995295110.png",
      "progress": 100,
      "milestone": "Ready for Pickup",
      "timeline": [
        {"title": "Cutting Phase", "time": "May 1", "completed": true},
        {"title": "Stitching", "time": "May 2", "completed": true},
        {"title": "QC Passed", "time": "May 3", "completed": true},
        {"title": "Ready for Pickup", "time": "May 4", "completed": true},
      ],
    },
    {
      "id": "#DF-7721",
      "name": "Silk Evening Gown",
      "status": "Stitching",
      "image": "assets/images/silk_gown_1777995259644.png",
      "progress": 40,
      "milestone": "Stitching in progress",
      "timeline": [
        {"title": "Measurement Taken", "time": "May 4", "completed": true},
        {"title": "Fabric Sourced", "time": "May 5", "completed": true},
        {"title": "Stitching", "time": "In Progress", "completed": false},
        {"title": "Embroidery", "time": "Pending", "completed": false},
      ],
    },
  ].obs;

  final processedActivities = <Map<String, dynamic>>[
    {
      "title": "Cutting Phase Started",
      "subtitle": "Navy Blue Tuxedo has moved to cutting department",
      "timeAgo": "2h ago",
      "type": "movement",
    },
    {
      "title": "Quality Check Passed",
      "subtitle": "Grey Slim Fit Suit passed final inspection",
      "timeAgo": "5h ago",
      "type": "approval",
    },
    {
      "title": "Order #DF-7721 Placed",
      "subtitle": "New order for Silk Evening Gown confirmed",
      "timeAgo": "1d ago",
      "type": "submission",
    },
  ].obs;

  void navigateToFullActivityList() {
    // Navigate to activity list
  }
}
