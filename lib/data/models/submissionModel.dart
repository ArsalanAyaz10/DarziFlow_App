class SubmissionFile {
  final String url;
  final String publicId;
  final String resourceType;

  SubmissionFile({
    required this.url,
    required this.publicId,
    required this.resourceType,
  });
}

class HistoryItem {
  final String action;
  final String actedBy;
  final DateTime actedAt;
  final String? comment;

  HistoryItem({
    required this.action,
    required this.actedBy,
    required this.actedAt,
    this.comment,
  });
}
