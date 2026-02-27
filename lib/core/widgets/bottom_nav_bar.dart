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
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: currentIndex,
        onTap: onTap ?? _handleNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree_outlined),
            activeIcon: Icon(Icons.account_tree),
            label: 'Workflows',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        break;
      case 1: // Orders
        Get.toNamed('/orders');
        break;
      case 2: // Workflows
        Get.toNamed('/workflows');
        break;
      case 3: // Messages
        Get.toNamed('/messages');
        break;
      case 4: // Profile
        Get.toNamed('/profile');
        break;
    }
  }
}
