class SubmissionFile {
  final String url;
  final String publicId;
  final String resourceType;

  SubmissionFile({
    required this.url,
    required this.publicId,
    required this.resourceType,
  });

  factory SubmissionFile.fromJson(Map<String, dynamic> json) {
    return SubmissionFile(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      resourceType: json['resourceType'] ?? 'image',
    );
  }
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
