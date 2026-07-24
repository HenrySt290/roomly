import 'package:equatable/equatable.dart';
import 'package:roomly/features/profile/domain/entities/user_entity.dart';

class OwnerProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String? aadharNumber;
  final String? panNumber;
  final KYCStatus kycStatus;
  final String? kycRejectionReason;
  final DateTime? kycVerifiedAt;
  final int totalListings;
  final int occupiedRooms;
  final double totalRevenue;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const OwnerProfileEntity({
    required this.id,
    required this.userId,
    this.aadharNumber,
    this.panNumber,
    this.kycStatus = KYCStatus.pending,
    this.kycRejectionReason,
    this.kycVerifiedAt,
    this.totalListings = 0,
    this.occupiedRooms = 0,
    this.totalRevenue = 0.0,
    this.createdAt = const DateTime.now(),
    this.updatedAt,
  });

  OwnerProfileEntity copyWith({
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
    return OwnerProfileEntity(
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

  bool get isKycVerified => kycStatus == KYCStatus.verified;
  bool get canCreateListing => kycStatus == KYCStatus.verified;

  @override
  List<Object?> get props => [
        id,
        userId,
        aadharNumber,
        panNumber,
        kycStatus,
        kycRejectionReason,
        kycVerifiedAt,
        totalListings,
        occupiedRooms,
        totalRevenue,
        createdAt,
        updatedAt,
      ];
}
