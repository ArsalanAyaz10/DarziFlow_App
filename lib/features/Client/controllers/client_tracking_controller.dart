import 'package:dariziflow_app/data/models/orderCard_model.dart';
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
  ClientTrackingController(this.repository);

  var orderId = ''.obs;
  var order = Rxn<OrderModel>();
  var isLoading = true.obs;
  var events = <TrackingEvent>[].obs;

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
  double get progressValue => totalSteps > 0 ? currentStep / totalSteps : 0.0;
  String get displayProgress => "${(progressValue * 100).round()}%";

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

      final response = await repository.fetchOrderById(orderId.value);
      if (response != null) {
        final data = (response as Map<String, dynamic>).containsKey('order')
            ? response['order'] as Map<String, dynamic>
            : response;

        order.value = OrderModel.fromJson(data);
        _generateEvents();
      }
    } catch (e) {
      debugPrint("Error fetching order tracking: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _generateEvents() {
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
