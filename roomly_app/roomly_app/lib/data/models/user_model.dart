import '../entities/user_entity.dart';

/// Data model for User
/// Implements serialization/deserialization for API communication
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.phone,
    required super.role,
    required super.name,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.createdAt,
    required super.updatedAt,
    this.avatarUrl,
    this.ownerProfileId,
    this.tenantProfileId,
  });

  final String? avatarUrl;
  final int? ownerProfileId;
  final int? tenantProfileId;

  /// Factory constructor from JSON (API Response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'guest'),
      name: json['name'] ?? '',
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
      avatarUrl: json['avatar_url'],
      ownerProfileId: json['owner_profile_id'],
      tenantProfileId: json['tenant_profile_id'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'role': role.value,
      'name': name,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'avatar_url': avatarUrl,
      'owner_profile_id': ownerProfileId,
      'tenant_profile_id': tenantProfileId,
    };
  }

  /// Copy with method for immutable updates
  UserModel copyWith({
    int? id,
    String? email,
    String? phone,
    UserRole? role,
    String? name,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    int? ownerProfileId,
    int? tenantProfileId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      name: name ?? this.name,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ownerProfileId: ownerProfileId ?? this.ownerProfileId,
      tenantProfileId: tenantProfileId ?? this.tenantProfileId,
    );
  }

  /// Check if user is owner
  bool get isOwner => role == UserRole.owner;

  /// Check if user is tenant
  bool get isTenant => role == UserRole.tenant;

  /// Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is guest
  bool get isGuest => role == UserRole.guest;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: $role, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.phone == phone &&
        other.role == role &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, email, phone, role, name);
}
