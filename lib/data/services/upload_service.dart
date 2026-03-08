import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/core/storage/token_storage.dart';

class UploadService {
  final ApiClient apiClient;
  final Dio _dio = Dio();

  UploadService(this.apiClient);

  // Step 1: Get upload signature from backend
  Future<Map<String, dynamic>> getUploadSignature(String contextType) async {
    try {
      final response = await apiClient.post(
        "/upload/signature",
        data: {"contextType": contextType},
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to get upload signature: $e");
    }
  }

  // Step 2: Upload file to Cloudinary
  Future<Map<String, dynamic>> uploadToCloudinary({
    required File file,
    required String cloudName,
    required String apiKey,
    required String timestamp,
    required String signature,
    required String folder,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
        'folder': folder,
      });

      final response = await _dio.post(
        "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception("Failed to upload to Cloudinary: $e");
    }
  }

  // Complete upload flow for profile avatar
  Future<String> uploadProfileAvatar(File imageFile) async {
    try {
      // Step 1: Get signature
      final signatureData = await getUploadSignature("profile");

      // Step 2: Upload to Cloudinary
      final uploadResult = await uploadToCloudinary(
        file: imageFile,
        cloudName: signatureData['cloudName'],
        apiKey: signatureData['apiKey'],
        timestamp: signatureData['timestamp'].toString(),
        signature: signatureData['signature'],
        folder: signatureData['folder'],
      );

      // Step 3: Update profile with new avatar
      await updateProfileAvatar(
        uploadResult['secure_url'],
        uploadResult['public_id'],
        uploadResult['resource_type'],
      );

      return uploadResult['secure_url'];
    } catch (e) {
      rethrow;
    }
  }

  // Step 3: Update profile avatar in backend
  Future<void> updateProfileAvatar(
    String url,
    String publicId,
    String resourceType,
  ) async {
    try {
      await apiClient.put(
        "/profile/avatar",
        data: {"url": url, "publicId": publicId, "resourceType": resourceType},
      );

      // After successfully updating on backend, update local storage
      await _updateLocalStorageWithAvatar(url, publicId);
    } catch (e) {
      throw Exception("Failed to update profile avatar: $e");
    }
  }

  // Helper method to update local storage with new avatar
  Future<void> _updateLocalStorageWithAvatar(
    String url,
    String publicId,
  ) async {
    try {
      final user = await TokenStorage.getUser();
      if (user != null) {
        // Update the avatar object in the user data
        user['avatar'] = {'url': url, 'publicId': publicId};
        await TokenStorage.saveUser(user);
      }
    } catch (e) {
      print("Error updating local storage with avatar: $e");
    }
  }
}
