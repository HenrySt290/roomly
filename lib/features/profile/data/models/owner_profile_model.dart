import 'package:roomly/features/profile/domain/entities/export.dart';

class OwnerProfileModel extends OwnerProfileEntity {
  const OwnerProfileModel({
    required super.id,
    required super.userId,
    super.aadharNumber,
    super.panNumber,
    super.kycStatus,
    super.kycRejectionReason,
    super.kycVerifiedAt,
    super.totalListings,
    super.occupiedRooms,
    super.totalRevenue,
    super.createdAt,
    super.updatedAt,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) {
    return OwnerProfileModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      aadharNumber: json['aadhar_number'],
      panNumber: json['pan_number'],
      kycStatus: KYCStatus.values.firstWhere(
        (e) => e.toString() == 'KYCStatus.${json['kyc_status']}',
        orElse: () => KYCStatus.pending,
      ),
      kycRejectionReason: json['kyc_rejection_reason'],
      kycVerifiedAt: json['kyc_verified_at'] != null
          ? DateTime.parse(json['kyc_verified_at'])
          : null,
      totalListings: json['total_listings'] ?? 0,
      occupiedRooms: json['occupied_rooms'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'aadhar_number': aadharNumber,
      'pan_number': panNumber,
      'kyc_status': kycStatus.toString().split('.').last,
      'kyc_rejection_reason': kycRejectionReason,
      'kyc_verified_at': kycVerifiedAt?.toIso8601String(),
      'total_listings': totalListings,
      'occupied_rooms': occupiedRooms,
      'total_revenue': totalRevenue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OwnerProfileModel copyWith({
    String? id,
    String? userId,
    String? aadharNumber,
    String? panNumber,
    KYCStatus? kycStatus,
    String? kycRejectionReason,
    DateTime? kycVerifiedAt,
    int? totalListings,
    int? occupiedRooms,
    double? totalRevenue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OwnerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      kycStatus: kycStatus ?? this.kycStatus,
      kycRejectionReason: kycRejectionReason ?? this.kycRejectionReason,
      kycVerifiedAt: kycVerifiedAt ?? this.kycVerifiedAt,
      totalListings: totalListings ?? this.totalListings,
      occupiedRooms: occupiedRooms ?? this.occupiedRooms,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
