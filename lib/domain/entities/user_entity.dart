import 'package:equatable/equatable.dart';

enum UserRole {
  tenant('tenant'),
  owner('owner'),
  admin('admin'),
  guest('guest');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.guest,
    );
  }
}

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.profileImage,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.fromString(json['role'] ?? 'tenant'),
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isTenant => role == UserRole.tenant;
  bool get isOwner => role == UserRole.owner;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        isEmailVerified,
        isPhoneVerified,
        profileImage,
        createdAt,
        updatedAt,
      ];

  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
