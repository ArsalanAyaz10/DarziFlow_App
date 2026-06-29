import 'dart:developer' as dev;
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:dariziflow_app/features/Profile/repositories/profile_repository.dart';
import 'package:get/get.dart';

class ProfileViewController extends GetxController {
  final ProfileRepository repository;

  ProfileViewController({required this.repository});

  final Rx<AuthModel?> userProfile = Rx<AuthModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  late String userId;
  late String fallbackName;
  late String fallbackAvatar;

  @override
  void onInit() {
    super.onInit();
    
    // Extract arguments
    final args = Get.arguments as Map<String, dynamic>?;
    userId = args?['userId'] ?? '';
    fallbackName = args?['fallbackName'] ?? 'Unknown User';
    fallbackAvatar = args?['fallbackAvatar'] ?? '';

    if (userId.isNotEmpty) {
      _fetchUserProfile();
    } else {
      errorMessage.value = "Invalid user ID.";
      isLoading.value = false;
    }
  }

  Future<void> _fetchUserProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final user = await repository.getUserById(userId);
      userProfile.value = user;
    } catch (e) {
      errorMessage.value = "Failed to load profile. Please try again.";
      dev.log("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
