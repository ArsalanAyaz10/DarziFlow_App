import 'package:dariziflow_app/data/models/submissionModel.dart';

class CheckpointModel {
  final String name;
  final String status;

  final bool qcRequired;

  final List<SubmissionFile> submissionFiles;

  final List<HistoryItem> history;

  CheckpointModel({
    required this.name,
    required this.status,
    required this.qcRequired,
    required this.submissionFiles,
    required this.history,
  });

  bool get isRejected => status == "QC_REJECTED";
  bool get isApproved => status == "QC_APPROVED";
  bool get isPending => status == "PENDING";
}