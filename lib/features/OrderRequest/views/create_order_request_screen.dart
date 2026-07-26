import 'dart:io';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/widgets/custom_appbar.dart';
import 'package:dariziflow_app/features/OrderRequest/controllers/order_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateOrderRequestScreen extends StatefulWidget {
  const CreateOrderRequestScreen({super.key});

  @override
  State<CreateOrderRequestScreen> createState() => _CreateOrderRequestScreenState();
}

class _CreateOrderRequestScreenState extends State<CreateOrderRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  
  String? _selectedType;
  final List<String> _types = ['PANT', 'SHORTS', 'JACKET', 'OTHER'];
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderRequestController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.atelierBackgroundDark : AppColors.atelierBackgroundLight,
      appBar: const CustomAppBar(
        title: 'New Order Request',
        showBackButton: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Request Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textColorDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Order Name",
                      hintText: "e.g. Navy Silk Tuxedo",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: "Type / Category",
                      border: OutlineInputBorder(),
                    ),
                    items: _types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    },
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Tell us about your requirements...",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: isDark ? AppColors.atelierSurfaceDark : AppColors.grey.withValues(alpha:0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: const Text("Target Due Date"),
                    subtitle: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
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
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Initial Tech Pack / References",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.textColorDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // File picker UI section
                  Obx(() {
                    return Column(
                      children: [
                        if (controller.pickedFiles.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.pickedFiles.length,
                            itemBuilder: (context, index) {
                              final file = controller.pickedFiles[index];
                              final fileName = file.path.split(Platform.pathSeparator).last;
                              return ListTile(
                                leading: const Icon(Icons.insert_drive_file),
                                title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.error),
                                  onPressed: () => controller.removeFile(index),
                                ),
                              );
                            },
                          ),
                        if (controller.pickedFiles.isNotEmpty) const SizedBox(height: 12),
                        GestureDetector(
                          onTap: controller.pickFiles,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.atelierTonalGrey.withValues(alpha:0.2),
                              border: Border.all(
                                color: AppColors.atelierTonalGrey,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 40, color: AppColors.atelierTonalGrey),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to upload files",
                                  style: TextStyle(
                                    color: AppColors.atelierTonalGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _selectedType != null) {
                          final success = await controller.submitRequest(
                            name: _nameController.text,
                            type: _selectedType!,
                            description: _descController.text,
                            targetDueDate: _selectedDate,
                          );
                          if (success) Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.atelierSilkGreen,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Obx(() => controller.isLoading.value 
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : const Text(
                            "Submit Request", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          )
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
