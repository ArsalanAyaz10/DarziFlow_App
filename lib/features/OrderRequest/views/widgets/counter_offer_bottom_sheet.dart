import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/order_request_model.dart';
import 'package:dariziflow_app/features/OrderRequest/controllers/order_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CounterOfferBottomSheet extends StatefulWidget {
  final OrderRequestModel request;

  const CounterOfferBottomSheet({super.key, required this.request});

  @override
  State<CounterOfferBottomSheet> createState() => _CounterOfferBottomSheetState();
}

class _CounterOfferBottomSheetState extends State<CounterOfferBottomSheet> {
  final OrderRequestController controller = Get.find<OrderRequestController>();
  
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late List<String> _departments;
  late List<String> _requiredDocs;

  @override
  void initState() {
    super.initState();
    final latestProposal = widget.request.latestProposal;
    
    _amountController = TextEditingController(
      text: latestProposal?.proposedAmount?.toString() ?? '',
    );
    _selectedDate = latestProposal?.proposedDueDate ?? DateTime.now().add(const Duration(days: 14));
    
    // Copy arrays to allow local editing
    _departments = List.from(latestProposal?.departmentSequenceIds ?? []);
    _requiredDocs = List.from(latestProposal?.proposedRequiredDocs ?? []);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _moveDepartment(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final String item = _departments.removeAt(oldIndex);
      _departments.insert(newIndex, item);
    });
  }

  void _moveDepartmentUp(int index) {
    if (index > 0) {
      _moveDepartment(index, index - 1);
    }
  }

  void _moveDepartmentDown(int index) {
    if (index < _departments.length - 1) {
      // ReorderableListView's logic requires newIndex to be index+2 when moving down 1 spot
      // But since we are directly mutating the list, we just swap or remove/insert.
      setState(() {
        final String item = _departments.removeAt(index);
        _departments.insert(index + 1, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.atelierSurfaceDark : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            "Draft Counter-Offer",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount & Date
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Proposed Amount",
                            prefixText: "Rs. ",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Due Date",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              "${_selectedDate.toLocal()}".split(' ')[0],
                              style: TextStyle(
                                color: isDark ? AppColors.white : AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Departments (Reorderable)
                  Text(
                    "Department Sequence",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Drag or use arrows to reorder steps.",
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                  const SizedBox(height: 8),
                  
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey.withValues(alpha:0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _departments.length,
                      onReorder: _moveDepartment,
                      itemBuilder: (context, index) {
                        final dept = _departments[index];
                        return ListTile(
                          key: ValueKey(dept),
                          title: Text(dept),
                          tileColor: isDark ? AppColors.atelierBackgroundDark : AppColors.lightGrey,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_up),
                                onPressed: index > 0 ? () => _moveDepartmentUp(index) : null,
                                color: index > 0 ? AppColors.primaryBlue : AppColors.grey,
                              ),
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                onPressed: index < _departments.length - 1 ? () => _moveDepartmentDown(index) : null,
                                color: index < _departments.length - 1 ? AppColors.primaryBlue : AppColors.grey,
                              ),
                              const Icon(Icons.drag_handle, color: AppColors.grey),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Required Docs
                  Text(
                    "Required Documents",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _requiredDocs.map((doc) {
                      return InputChip(
                        label: Text(doc),
                        onDeleted: () {
                          setState(() {
                            _requiredDocs.remove(doc);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add new doc dialog
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Document requirement"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.transparent,
                      elevation: 0,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.atelierSurfaceDark : AppColors.white,
              border: Border(top: BorderSide(color: AppColors.grey.withValues(alpha:0.2))),
            ),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(_amountController.text);
                final success = await controller.submitProposal(
                  requestId: widget.request.id,
                  amount: amount,
                  dueDate: _selectedDate,
                  departmentSequenceIds: _departments,
                  // files/docs would go here depending on service signature
                );
                if (success) {
                  Get.back(); // close bottom sheet
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.atelierSilkGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator(color: AppColors.white)
                  : const Text("Submit Proposal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}
