// ignore_for_file: constant_identifier_names

class AttachedFileModel {
  final String fileName;
  final String fileUrl;
  final String publicId;
  final String resourceType;

  AttachedFileModel({
    required this.fileName,
    required this.fileUrl,
    required this.publicId,
    this.resourceType = 'auto',
  });

  factory AttachedFileModel.fromJson(Map<String, dynamic> json) {
    return AttachedFileModel(
      fileName: json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      publicId: json['publicId'] ?? '',
      resourceType: json['resourceType'] ?? 'auto',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'publicId': publicId,
      'resourceType': resourceType,
    };
  }
}

class ProposalModel {
  final String? id;
  final String proposedByRole;
  final int? proposedAmount;
  final String proposedCurrency;
  final DateTime? proposedDueDate;
  final List<String> proposedRequiredDocs;
  final List<String> departmentSequenceIds;
  final String? qcMemberId;
  final List<AttachedFileModel> proposedReferenceFiles;
  final String? remarks;
  final DateTime? createdAt;

  ProposalModel({
    this.id,
    required this.proposedByRole,
    this.proposedAmount,
    this.proposedCurrency = 'Rs.',
    this.proposedDueDate,
    this.proposedRequiredDocs = const [],
    this.departmentSequenceIds = const [],
    this.qcMemberId,
    this.proposedReferenceFiles = const [],
    this.remarks,
    this.createdAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['_id'],
      proposedByRole: json['proposedByRole'] ?? 'CLIENT',
      proposedAmount: json['proposedAmount'] != null
          ? (json['proposedAmount'] as num).toInt()
          : null,
      proposedCurrency: json['proposedCurrency'] ?? 'Rs.',
      proposedDueDate: json['proposedDueDate'] != null
          ? DateTime.tryParse(json['proposedDueDate'].toString())
          : null,
      proposedRequiredDocs: List<String>.from(
        json['proposedRequiredDocs'] ?? [],
      ),
      departmentSequenceIds: List<String>.from(
        json['departmentSequenceIds'] ?? [],
      ),
      qcMemberId: json['qcMemberId']?.toString(),
      proposedReferenceFiles: (json['proposedReferenceFiles'] as List? ?? [])
          .map((f) => AttachedFileModel.fromJson(f))
          .toList(),
      remarks: json['remarks'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'proposedByRole': proposedByRole,
      if (proposedAmount != null) 'proposedAmount': proposedAmount,
      'proposedCurrency': proposedCurrency,
      if (proposedDueDate != null)
        'proposedDueDate': proposedDueDate?.toIso8601String(),
      'proposedRequiredDocs': proposedRequiredDocs,
      'departmentSequenceIds': departmentSequenceIds,
      if (qcMemberId != null) 'qcMemberId': qcMemberId,
      'proposedReferenceFiles': proposedReferenceFiles
          .map((f) => f.toJson())
          .toList(),
      if (remarks != null) 'remarks': remarks,
      if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    };
  }
}

enum OrderRequestStatus { PENDING_ADMIN, PENDING_CLIENT, CONVERTED, CANCELED }

class OrderRequestModel {
  final String id;
  final String name;
  final String type;
  final String description;
  final DateTime targetDueDate;
  final List<AttachedFileModel> originalReferenceFiles;

  // Client Info (Encrypted on backend, but decrypted for client usage)
  final String clientName;
  final String clientEmail;
  final String clientId;

  final List<ProposalModel> proposals;
  final String? finalOrderId;
  final OrderRequestStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderRequestModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.targetDueDate,
    this.originalReferenceFiles = const [],
    required this.clientName,
    required this.clientEmail,
    required this.clientId,
    this.proposals = const [],
    this.finalOrderId,
    this.status = OrderRequestStatus.PENDING_ADMIN,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderRequestModel.fromJson(Map<String, dynamic> json) {
    return OrderRequestModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      targetDueDate:
          DateTime.tryParse(json['targetDueDate']?.toString() ?? '') ??
          DateTime.now(),
      originalReferenceFiles: (json['originalReferenceFiles'] as List? ?? [])
          .map((f) => AttachedFileModel.fromJson(f))
          .toList(),
      clientName: json['clientName'] ?? '',
      clientEmail: json['clientEmail'] ?? '',
      clientId: json['clientId']?.toString() ?? '',
      proposals: (json['proposals'] as List? ?? [])
          .map((p) => ProposalModel.fromJson(p))
          .toList(),
      finalOrderId: json['finalOrderId']?.toString(),
      status: _parseStatus(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  static OrderRequestStatus _parseStatus(String? status) {
    switch (status) {
      case 'PENDING_CLIENT':
        return OrderRequestStatus.PENDING_CLIENT;
      case 'CONVERTED':
        return OrderRequestStatus.CONVERTED;
      case 'CANCELED':
        return OrderRequestStatus.CANCELED;
      case 'PENDING_ADMIN':
      default:
        return OrderRequestStatus.PENDING_ADMIN;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'description': description,
      'targetDueDate': targetDueDate.toIso8601String(),
      'originalReferenceFiles': originalReferenceFiles
          .map((f) => f.toJson())
          .toList(),
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientId': clientId,
      'proposals': proposals.map((p) => p.toJson()).toList(),
      if (finalOrderId != null) 'finalOrderId': finalOrderId,
      'status': status.name,
    };
  }

  ProposalModel? get latestProposal {
    if (proposals.isEmpty) return null;
    return proposals.last;
  }

  bool get isPendingAction {
    // Logic to determine if the current user needs to take action
    // For Client, action is needed if status is PENDING_CLIENT
    return status == OrderRequestStatus.PENDING_CLIENT;
  }
}
