import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/data/services/socket_service.dart';
import 'package:dariziflow_app/features/Messages/controllers/chat_list_controller.dart';
import 'package:dariziflow_app/features/Messages/repositories/chat_repository.dart';
import 'package:dariziflow_app/features/Messages/service/chat_service.dart';
import 'package:get/get.dart';

class ChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(
      () => ChatService(apiClient: Get.find<ApiClient>()),
    );
    Get.lazyPut<ChatRepository>(
      () => ChatRepository(chatService: Get.find<ChatService>()),
    );
    Get.lazyPut<ChatListController>(
      () => ChatListController(
        repository: Get.find<ChatRepository>(),
        socketService: Get.find<SocketService>(),
      ),
    );
  }
}
