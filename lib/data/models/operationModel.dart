import 'package:dariziflow_app/data/models/checkpointModel.dart';

class OperationModel {
  final String id;
  final String name;
  final String status;

  final List<CheckpointModel> checkpoints;

  OperationModel({
    required this.id,
    required this.name,
    required this.status,
    required this.checkpoints,
  });

  bool get isCompleted {
    if (status == "COMPLETED") return true;
    if (checkpoints.isEmpty) return false;
    return checkpoints.every((cp) =>
        cp.status == 'COMPLETED' ||
        cp.status == 'QC_APPROVED' ||
        cp.status == 'APPROVED');
  }
}
