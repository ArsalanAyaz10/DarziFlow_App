import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/features/OrderRequest/controllers/order_request_controller.dart';
import 'package:dariziflow_app/features/OrderRequest/views/widgets/counter_offer_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderRequestDetailsScreen extends StatefulWidget {
  const OrderRequestDetailsScreen({super.key});

  @override
  State<OrderRequestDetailsScreen> createState() => _OrderRequestDetailsScreenState();
}

class _OrderRequestDetailsScreenState extends State<OrderRequestDetailsScreen> {
  final OrderRequestController controller = Get.find<OrderRequestController>();
  late String requestId;

  @override
  void initState() {
    super.initState();
    requestId = Get.arguments as String;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRequestDetails(requestId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.atelierBackgroundDark : AppColors.background,
      appBar: CustomAppBar(
        title: 'Request Details',
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'cancel') {
                // TODO: Implement cancel request
                Get.snackbar("Notice", "Cancel Request to be implemented.");
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'cancel',
                child: Text('Cancel Request'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentRequest.value == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        }

        final request = controller.currentRequest.value;
        if (request == null) {
          return const Center(child: Text("Request details not found."));
        }

        return Column(
          children: [
            // Pinned Header: Original Request
            _buildHeaderCard(request, isDark),
            
            // Body: Timeline of proposals
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: request.proposals.length,
                itemBuilder: (context, index) {
                  final proposal = request.proposals[index];
                  return _buildProposalBubble(proposal, isDark);
                },
              ),
            ),

            // Footer: Make Counter-Offer Button
            if (request.status == OrderRequestStatus.PENDING_CLIENT)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.atelierSurfaceDark : AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Get.bottomSheet(
                      CounterOfferBottomSheet(request: request),
                      isScrollControlled: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Make Counter-Offer",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderCard(OrderRequestModel request, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.atelierTonalGrey.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  request.type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textColorDark.withValues(alpha:0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalBubble(ProposalModel proposal, bool isDark) {
    final isAdmin = proposal.proposedByRole == 'ADMIN';
    
    // Formatting values
    final amountStr = proposal.proposedAmount != null 
        ? "${proposal.proposedCurrency} ${proposal.proposedAmount}" 
        : "TBD";
    final dateStr = proposal.proposedDueDate != null 
        ? DateFormat('MMM dd, yyyy').format(proposal.proposedDueDate!) 
        : "TBD";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAdmin) 
            const CircleAvatar(
              backgroundColor: AppColors.atelierTonalGrey,
              radius: 16,
              child: Icon(Icons.support_agent, size: 16, color: AppColors.white),
            ),
          if (isAdmin) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.white : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12).copyWith(
                  topLeft: isAdmin ? const Radius.circular(0) : const Radius.circular(12),
                  topRight: isAdmin ? const Radius.circular(12) : const Radius.circular(0),
                ),
                border: Border.all(
                  color: isAdmin ? AppColors.grey.withValues(alpha:0.3) : AppColors.transparent,
                ),
                boxShadow: isAdmin ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha:0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin ? "DarziFlow Admin" : "You (Counter-Offer)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? AppColors.primaryBlue : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Details Grid
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 16, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(amountStr, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.black)),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.black)),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  const Text("Departments Sequence:", style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: proposal.departmentSequenceIds.map((deptId) {
                      return Chip(
                        label: Text(deptId),
                        labelStyle: const TextStyle(fontSize: 10, color: AppColors.black),
                        backgroundColor: AppColors.atelierTonalGrey.withValues(alpha:0.3),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  
                  if (proposal.remarks != null && proposal.remarks!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      proposal.remarks!,
                      style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.black),
                    ),
                  ]
                ],
              ),
            ),
          ),
          
          if (!isAdmin) const SizedBox(width: 8),
          if (!isAdmin)
            const CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              radius: 16,
              child: Icon(Icons.person, size: 16, color: AppColors.white),
            ),
        ],
      ),
    );
  }
}
