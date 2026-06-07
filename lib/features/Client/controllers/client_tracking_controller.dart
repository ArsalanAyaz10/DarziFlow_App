import 'package:dariziflow_app/data/models/orderCard_model.dart';
import 'package:dariziflow_app/features/Client/services/client_service.dart';
import 'package:dariziflow_app/features/Orders/repository/order_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum TrackingEventType { completed, rejected, pending }

class TrackingEvent {
  final String title;
  final String? description;
  final DateTime date;
  final TrackingEventType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  TrackingEvent({
    required this.title,
    this.description,
    required this.date,
    required this.type,
    this.actionLabel,
    this.onAction,
  });
}

class ClientTrackingController extends GetxController {
  
  final OrderRepository repository;
  final ClientService _clientService = Get.find<ClientService>();

  ClientTrackingController(this.repository);

  var orderId = ''.obs;
  var order = Rxn<OrderModel>();
  var isLoading = true.obs;
  var events = <TrackingEvent>[].obs;
  var progressPercentage = 0.0.obs;

  int get totalSteps => order.value?.operations.length ?? 0;

  int get currentStep {
    final o = order.value;
    if (o == null) return 0;
    int step = 0;
    for (int i = 0; i < o.operations.length; i++) {
      if (o.operations[i].status == 'COMPLETED') {
        step = i + 1;
      } else {
        break;
      }
    }
    return step;
  }

  int get displayTotalSteps => totalSteps > 0 ? totalSteps : 1;
  double get progressValue => progressPercentage.value / 100.0;
  String get displayProgress => "${progressPercentage.value.round()}%";

  List<String> get stepNames {
    final o = order.value;
    if (o == null || o.operations.isEmpty) return ["Pending"];
    return o.operations.map((op) => op.name).toList();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      orderId.value = Get.arguments['orderId'] ?? '';
    }
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      isLoading.value = true;
      if (orderId.value.isEmpty) return;

      // 1. Fetch main order details
      final response = await repository.fetchOrderById(orderId.value);
      if (response != null) {
        final data = (response as Map<String, dynamic>).containsKey('order')
            ? response['order'] as Map<String, dynamic>
            : response;

        order.value = OrderModel.fromJson(data);
      }

      // 2. Fetch precise progress
      try {
        final progressData = await _clientService.getOrderProgress(orderId.value);
        if (progressData['progress'] != null) {
          progressPercentage.value = (progressData['progress'] as num).toDouble();
        } else {
          _calculateFallbackProgress();
        }
      } catch (e) {
        debugPrint("Error fetching precise order progress: $e");
        _calculateFallbackProgress();
      }

      // 3. Fetch unified timeline history
      try {
        final timelineData = await _clientService.getOrderTimeline(orderId.value);
        if (timelineData.isNotEmpty) {
          _parseTimelineEvents(timelineData);
        } else {
          _generateFallbackEvents();
        }
      } catch (e) {
        debugPrint("Error fetching order timeline: $e");
        _generateFallbackEvents();
      }

    } catch (e) {
      debugPrint("Error fetching order tracking details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateFallbackProgress() {
    if (totalSteps > 0) {
      progressPercentage.value = (currentStep / totalSteps) * 100.0;
    } else {
      progressPercentage.value = 0.0;
    }
  }

  TrackingEventType _mapActionToType(String action) {
    final act = action.toUpperCase();
    if (act.contains('REJECT')) {
      return TrackingEventType.rejected;
    }
    return TrackingEventType.completed;
  }

  void _parseTimelineEvents(List<dynamic> timelineData) {
    List<TrackingEvent> tempEvents = [];
    for (var item in timelineData) {
      if (item is Map<String, dynamic>) {
        final dateStr = item['createdAt'] ?? '';
        final date = DateTime.tryParse(dateStr) ?? DateTime.now();
        final action = item['action'] ?? '';

        tempEvents.add(
          TrackingEvent(
            title: item['displayTitle'] ?? 'Update',
            description: item['displayDescription'] ?? item['comment'],
            date: date,
            type: _mapActionToType(action),
          ),
        );
      }
    }
    tempEvents.sort((a, b) => b.date.compareTo(a.date));
    events.assignAll(tempEvents);
  }

  void _generateFallbackEvents() {
    final o = order.value;
    if (o == null) return;

    List<TrackingEvent> tempEvents = [];

    if (o.createdAt != null) {
      tempEvents.add(
        TrackingEvent(
          title: "Order Placed",
          description: "Your order has been registered.",
          date: o.createdAt!,
          type: TrackingEventType.completed,
        ),
      );
    }

    bool allDocsApproved =
        o.requiredDocuments.isNotEmpty &&
        o.requiredDocuments.every((doc) => doc.status == 'APPROVED');

    if (allDocsApproved) {
      tempEvents.add(
        TrackingEvent(
          title: "Documents Fulfilled & Approved",
          description: "All required blueprints and measurements verified.",
          date: o.updatedAt ?? DateTime.now(),
          type: TrackingEventType.completed,
        ),
      );
    }

    for (var op in o.operations) {
      for (var cp in op.checkpoints) {
        for (var history in cp.history) {
          TrackingEventType type = TrackingEventType.completed;
          String title = "";
          String? description = history.comment;

          if (history.action == 'APPROVE' || history.action == 'QC_APPROVE') {
            title = "Checkpoint Approved: ${cp.name}";
            type = TrackingEventType.completed;
          } else if (history.action == 'REJECT') {
            title = "Checkpoint Reviewed: ${cp.name}";
            type = TrackingEventType.rejected;
            description = "Status: Rejected - ${history.comment}";
          } else if (history.action == 'SUBMIT') {
            title = "Work Submitted: ${cp.name}";
            type = TrackingEventType.completed;
          }

          if (title.isNotEmpty) {
            tempEvents.add(
              TrackingEvent(
                title: title,
                description: description,
                date: history.actedAt,
                type: type,
              ),
            );
          }
        }
      }

      if (op.status == 'COMPLETED') {
        tempEvents.add(
          TrackingEvent(
            title: "Operation Finished: ${op.name}",
            date: o.updatedAt ?? DateTime.now(),
            type: TrackingEventType.completed,
          ),
        );
      }
    }

    tempEvents.sort((a, b) => b.date.compareTo(a.date));
    events.assignAll(tempEvents);
  }
}

