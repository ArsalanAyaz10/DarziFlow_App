import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/Messages/controllers/chat_controller.dart';
import 'package:dariziflow_app/features/Messages/repositories/chat_repository.dart';
import 'package:dariziflow_app/features/Messages/service/chat_service.dart';
import 'package:get/get.dart';

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatService>()) {
      Get.lazyPut<ChatService>(
        () => ChatService(apiClient: Get.find<ApiClient>()),
      );
    }
    // ChatRepository may already be registered from ChatListBinding — safe to re-put
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut<ChatRepository>(
        () => ChatRepository(chatService: Get.find<ChatService>()),
      );
    }

    Get.lazyPut<ChatController>(
      () => ChatController(
        repository: Get.find<ChatRepository>(),
        socketService: Get.find<SocketService>(),
        uploadService: Get.find<UploadService>(),
      ),
    );
  }
}
