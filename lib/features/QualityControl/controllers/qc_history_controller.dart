import 'package:dariziflow_app/data/models/qc_history_model.dart';
import 'package:dariziflow_app/features/QualityControl/repositories/qc_repository.dart';
import 'package:get/get.dart';

class QcHistoryController extends GetxController {
  final QcRepository repository;
  QcHistoryController({required this.repository});

  var historyLogs = <QcHistoryModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final rawData = await repository.fetchQcHistory();
      historyLogs.value = rawData
          .map((json) => QcHistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } finally {
      isLoading.value = false;
    }
  }
}
