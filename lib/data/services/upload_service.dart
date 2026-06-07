import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as dev;

class UploadService {
  final ApiClient apiClient;
  final Dio _dio = Dio();

  UploadService(this.apiClient);

  Future<Map<String, dynamic>> getUploadSignature(
    String contextType, {
    String? orderId,
  }) async {
    try {
      final response = await apiClient.post(
        "upload/signature",
        data: {
          "contextType": contextType,
          "orderId": ?orderId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to get upload signature: $e");
    }
  }

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

  Future<String> uploadProfileAvatar(File imageFile) async {
    try {
      final signatureData = await getUploadSignature("profile");

      final uploadResult = await uploadToCloudinary(
        file: imageFile,
        cloudName: signatureData['cloudName'],
        apiKey: signatureData['apiKey'],
        timestamp: signatureData['timestamp'].toString(),
        signature: signatureData['signature'],
        folder: signatureData['folder'],
      );

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

  Future<void> updateProfileAvatar(
    String url,
    String publicId,
    String resourceType,
  ) async {
    try {
      await apiClient.put(
        "profile/avatar",
        data: {"url": url, "publicId": publicId, "resourceType": resourceType},
      );

      await _updateLocalStorageWithAvatar(url, publicId);
    } catch (e) {
      throw Exception("Failed to update profile avatar: $e");
    }
  }

  Future<void> _updateLocalStorageWithAvatar(
    String url,
    String publicId,
  ) async {
    try {
      final user = await AppStorage.getAuthUser();
      if (user != null) {
        await AppStorage.saveAuthUser(user.copyWith(
          avatar: AvatarModel(url: url, publicId: publicId),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log("Error updating local storage with avatar: $e");
      }
    }
  }

  Future<Map<String, dynamic>> getCheckpointUploadSignature({
    required String orderId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "contextType": "checkpoint",
        "orderId": orderId,
      };

      dev.log("Requesting Signature with Body: $body");

      final response = await apiClient.post("upload/signature", data: body);
      return response.data;
    } catch (e) {
      throw Exception("Failed to get checkpoint signature: $e");
    }
  }

  /// Requests a Cloudinary upload signature for a chat message attachment.
  Future<Map<String, dynamic>> getChatUploadSignature({
    required String chatRoomId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "contextType": "chat",
        "chatRoomId": chatRoomId,
      };

      dev.log("Requesting chat upload signature: $body");

      final response = await apiClient.post("upload/signature", data: body);
      return response.data;
    } catch (e) {
      throw Exception("Failed to get chat upload signature: $e");
    }
  }
}
