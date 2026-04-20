import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/deptHeadController.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/controllers/department_details_controller.dart';
import 'package:dariziflow_app/features/deptHeadDashboard/views/department_details_screen.dart';
import 'package:dariziflow_app/features/messages/views/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 2,
        showSelectedLabels: true,
        selectedFontSize: 15,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: onTap ?? _handleNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.corporate_fare_outlined),
            activeIcon: Icon(Icons.corporate_fare),
            label: 'Department',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  Future<void> _handleNavigation(int index) async {
    if (index == currentIndex) return;

    switch (index) {
      case 0: // Dashboard
        final role = await AppStorage.getUserRole();
        if (role?.toUpperCase() == "QC_MEMBER") {
          Get.offAllNamed(Routes.qcDashboard);
        } else if (role?.toUpperCase() == "DEPARTMENT_HEAD") {
          Get.offAllNamed(Routes.deptartmentHead);
        } else {
          Get.offAllNamed(Routes.login);
        }
        break;
      case 1: // Orders
        Get.offNamed(Routes.orders);
        break;
      case 2: // Department Details
        try {
          String? deptId;
          
          // 1. Try to get from active DeptHeadController
          if (Get.isRegistered<DeptHeadController>()) {
            deptId = Get.find<DeptHeadController>().departmentId.value;
          }
          
          // 2. If not found, fallback to local storage
          if (deptId == null || deptId.isEmpty) {
            final user = await AppStorage.getAuthUser();
            deptId = user?.department;
          }

          if (deptId != null && deptId.isNotEmpty) {
            // Ensure any existing controller with a different ID is replaced
            if (Get.isRegistered<DepartmentDetailsController>()) {
              Get.delete<DepartmentDetailsController>();
            }
            
            Get.put(
              DepartmentDetailsController(
                repository: Get.find(),
                departmentId: deptId,
              ),
            );
            Get.to(() => const DepartmentDetailsScreen());
          } else {
            Get.snackbar('Error', 'Department information not found');
          }
        } catch (e) {
          Get.snackbar('Error', 'Department information not available');
        }
        break;
      case 3: // Messages
        Get.to(() => const MessagesComingSoonScreen());
        break;
      case 4: // Profile
        Get.toNamed(Routes.profile);
        break;
    }
  }
}
