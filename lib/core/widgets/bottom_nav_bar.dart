import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/deptHeadController.dart';
import 'package:dariziflow_app/features/DepartmentHead/controllers/department_details_controller.dart';
import 'package:dariziflow_app/features/DepartmentHead/views/department_details_screen.dart';
import 'package:dariziflow_app/features/Messages/views/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({super.key, this.currentIndex = 0, this.onTap});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  // Load the role once when the nav bar initializes to prevent UI flickering
  Future<void> _loadRole() async {
    final role = await AppStorage.getUserRole();
    if (mounted) {
      setState(() {
        _userRole = role?.toUpperCase();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show an empty container of roughly the same height while loading
      return const SizedBox(height: 60);
    }

    final isQC = _userRole == 'QC_MEMBER';
    final isClient = _userRole == 'CLIENT';

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
        currentIndex: widget.currentIndex,
        onTap: widget.onTap ?? _handleNavigation,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 20),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          // --- DYNAMIC 3RD TAB ---
          if (isQC)
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            )
          else if (isClient)
            const BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Docs',
            )
          else
            const BottomNavigationBarItem(
              icon: Icon(Icons.corporate_fare_outlined),
              activeIcon: Icon(Icons.corporate_fare),
              label: 'Department',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
      ),
    );
  }

  Future<void> _handleNavigation(int index) async {
    if (index == widget.currentIndex) return;

    // Fallback to fetching if state isn't loaded for some reason
    final role = _userRole ?? (await AppStorage.getUserRole())?.toUpperCase();
    final isQC = role == "QC_MEMBER";

    switch (index) {
      case 0: // Dashboard
        if (isQC) {
          Get.offAllNamed(Routes.qcDashboard);
        } else if (role == "DEPARTMENT_HEAD") {
          Get.offAllNamed(Routes.deptartmentHead);
        } else if (role == "CLIENT") {
          Get.offAllNamed(Routes.clientDashboard);
        } else {
          Get.offAllNamed(Routes.login);
        }
        break;

      case 1: // Orders
        List<dynamic>? preloadedData;

        if (Get.isRegistered<DeptHeadController>()) {
          preloadedData = Get.find<DeptHeadController>().rawOrderData;
        }

        Get.offNamed(Routes.orders, arguments: preloadedData);
        break;

      case 2: // Dynamic Tab
        if (isQC) {
          Get.offNamed(Routes.qcHistory);
        } else if (role == "CLIENT") {
          Get.offNamed(Routes.clientDocs);
        } else {
          // --- DEPARTMENT HEAD NAVIGATION ---
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
        }
        break;

      case 3: // Messages
        Get.to(() => const MessagesComingSoonScreen());
        break;
    }
  }
}
