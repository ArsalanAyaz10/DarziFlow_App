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
  final _typeController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

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
                      color: isDark ? Colors.white : AppColors.black,
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
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: "Type / Category",
                      hintText: "e.g. Formal Wear",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: "Tell us about your requirements...",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
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
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await controller.submitRequest(
                            name: _nameController.text,
                            type: _typeController.text,
                            description: _descController.text,
                            targetDueDate: _selectedDate,
                            files: [], // To be implemented with file picker
                          );
                          if (success) Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.atelierSilkGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Obx(() => controller.isLoading.value 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit Request")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
