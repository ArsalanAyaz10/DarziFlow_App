class AvatarModel {
  final String url;
  final String publicId;

  const AvatarModel({
    required this.url,
    this.publicId = '',
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

class AuthModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? department;
  final AvatarModel? avatar;
  final String? passwordUpdatedAt;

  const AuthModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.avatar,
    this.passwordUpdatedAt,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      department: json['department']?.toString(),
      avatar: json['avatar'] != null && json['avatar'] is Map
          ? AvatarModel.fromJson(Map<String, dynamic>.from(json['avatar']))
          : null,
      passwordUpdatedAt: json['passwordUpdatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      if (department != null) 'department': department,
      if (avatar != null) 'avatar': avatar!.toJson(),
      if (passwordUpdatedAt != null) 'passwordUpdatedAt': passwordUpdatedAt,
    };
  }

  AuthModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? department,
    AvatarModel? avatar,
    String? passwordUpdatedAt,
  }) {
    return AuthModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      department: department ?? this.department,
      avatar: avatar ?? this.avatar,
      passwordUpdatedAt: passwordUpdatedAt ?? this.passwordUpdatedAt,
    );
  }

  String get avatarUrl => avatar?.url ?? '';

  String get formattedRole {
    switch (role) {
      case 'CLIENT':
        return 'Client';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'QC_MEMBER':
        return 'QC Member';
      default:
        return 'Unknown Role';
    }
  }
}
