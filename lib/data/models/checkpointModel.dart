import 'package:dariziflow_app/data/models/submissionModel.dart';

enum SubmissionType { text, image, video, document }

class CheckpointModel {
  final String id;
  final String name;
  final String status;
  final String submissionText;
  final bool qcRequired;
  final SubmissionType submissionType; //img,video,text,doc
  final int minUploads;
  final List<String> allowedTypes;

  final List<SubmissionFile> submissionFiles;

  final List<HistoryItem> history;

  CheckpointModel({
    required this.id,
    required this.submissionText,
    required this.name,
    required this.status,
    required this.qcRequired,
    required this.submissionFiles,
    required this.history,
    required this.submissionType,
    required this.minUploads,
    this.allowedTypes = const [],
  });

  bool get isRejected => status == "QC_REJECTED";
  bool get isApproved => status == "QC_APPROVED";
  bool get isCompleted => status == "COMPLETED";
  bool get toBeSubmitted => status == "TO_BE_SUBMITTED";
  bool get isQcPending => status == "QC_PENDING";
}
