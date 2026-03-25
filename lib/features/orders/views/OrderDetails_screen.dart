import 'package:dariziflow_app/features/orders/controllers/orderDetail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart'; 
import 'package:dariziflow_app/core/widgets/bottom_nav_bar.dart';

class OrderDetailsScreen extends GetView<OrderDetailController> {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onBackground),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Column(
          children: [
            Text(
              "#${controller.orderData['orderUniqueId']?.toString().substring(0, 8).toUpperCase() ?? 'ORD-0000'}",
              style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              controller.orderData['orderName'] ?? "Loading...",
              style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12),
            ),
          ],
        )),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {})],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressCard(context),
              const SizedBox(height: 25),
              _buildTimeline(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Production Progress", style: TextStyle(fontWeight: FontWeight.w600)),
              Text("${controller.progress.value}%", 
                style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: controller.progress.value / 100,
            backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.settings_suggest_outlined, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              RichText(text: TextSpan(
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 12),
                children: [
                  const TextSpan(text: "Current Phase: "),
                  TextSpan(
                    text: controller.orderData['operations']?[0]['name'].toString().toUpperCase() ?? "N/A",
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ]
              ))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    List operations = controller.orderData['operations'] ?? [];
    return Column(
      children: List.generate(operations.length, (index) {
        final op = operations[index];
        final isCompleted = op['status'] == 'COMPLETED';
        final isActive = op['status'] == 'PENDING' && (index == 0 || operations[index-1]['status'] == 'COMPLETED');

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.primaryGreen : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: isCompleted ? AppColors.primaryGreen : Colors.grey.withOpacity(0.5)),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : _getOpIcon(op['name']),
                      size: 18,
                      color: isCompleted ? Colors.white : Colors.grey,
                    ),
                  ),
                  if (index != operations.length - 1)
                    Expanded(child: VerticalDivider(thickness: 2, color: isCompleted ? AppColors.primaryGreen : Colors.grey.withOpacity(0.3))),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(op['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusBadge(op['status'], isActive),
                      ],
                    ),
                    if (isActive) _buildActiveCard(context, op),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActiveCard(BuildContext context, Map op) {
    final theme = Theme.of(context);
    List checkpoints = op['checkpoints'] ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          ...checkpoints.map((cp) => _buildCheckpointItem(context, cp)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed('/submit-checkpoint', arguments: op),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text("Submit Checkpoint", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheckpointItem(BuildContext context, Map cp) {
    bool isDone = ['APPROVED', 'QC_APPROVED'].contains(cp['status']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, 
               color: isDone ? AppColors.primaryGreen : Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cp['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                if (cp['status'] == 'QC_REJECTED')
                  const Text("Requires Attention", style: TextStyle(color: Colors.red, fontSize: 11)),
              ],
            ),
          ),
          if (isDone) const Text("Approved", style: TextStyle(color: AppColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isActive) {
    if (isActive) return _badge("ACTIVE PHASE", AppColors.primaryGreen);
    if (status == 'COMPLETED') return _badge("COMPLETED", Colors.grey);
    return _badge("UPCOMING", Colors.grey.withOpacity(0.5));
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _getOpIcon(String name) {
    if (name.contains("Design")) return Icons.architecture;
    if (name.contains("Cloth")) return Icons.content_cut;
    return Icons.inventory_2_outlined;
  }
}