import 'package:dariziflow_app/features/deptHeadDashboard/repositories/department_repository.dart';
import 'package:get/get.dart';

class DepartmentDetailsController extends GetxController {
  final DepartmentRepository repository;
  final String departmentId;

  DepartmentDetailsController({required this.repository, required this.departmentId});

  var isLoading = true.obs;
  
  var name = ''.obs;
  var description = ''.obs;
  var status = ''.obs;
  var managerName = ''.obs;
  var managerEmail = ''.obs;
  var operations = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    try {
      var data = await repository.fetchDepartmentById(departmentId);
      
      if (data.isEmpty) {
        final rawResponse = await repository.service.getDepartmentById(departmentId);
        if (rawResponse is Map<String, dynamic>) {
           if (rawResponse.containsKey('department')) {
               data = rawResponse['department'];
           } else {
               data = rawResponse;
           }
        }
      }

      name.value = data['name'] ?? 'Unknown';
      description.value = data['description'] ?? '';
      status.value = data['status'] ?? 'Unknown';

      if (data['departmentHead'] != null) {
        managerName.value = data['departmentHead']['name'] ?? 'Department Head';
        managerEmail.value = data['departmentHead']['email'] ?? '';
      } else {
        managerName.value = 'Department Head';
        managerEmail.value = 'No email available';
      }

      final opsList = data['operations'] as List? ?? [];
      operations.assignAll(opsList);

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch department details');
    } finally {
      isLoading.value = false;
    }
  }
}
