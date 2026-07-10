import 'package:equatable/equatable.dart';

class KycDocumentEntity extends Equatable {
  final String id;
  final String userId;
  final String documentType; // aadhar, pan, passport, driving_license
  final String documentUrl;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String? selfImageUrl;
  final KYCStatus status;
  final String? rejectionReason;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const KycDocumentEntity({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentUrl,
    this.frontImageUrl,
    this.backImageUrl,
    this.selfImageUrl,
    this.status = KYCStatus.pending,
    this.rejectionReason,
    this.verifiedAt,
    this.createdAt = const DateTime.now(),
    this.updatedAt,
  });

  KycDocumentEntity copyWith({
    String? id,
    String? userId,
    String? documentType,
    String? documentUrl,
    String? frontImageUrl,
    String? backImageUrl,
    String? selfImageUrl,
    KYCStatus? status,
    String? rejectionReason,
    DateTime? verifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KycDocumentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      documentType: documentType ?? this.documentType,
      documentUrl: documentUrl ?? this.documentUrl,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      selfImageUrl: selfImageUrl ?? this.selfImageUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        documentType,
        documentUrl,
        frontImageUrl,
        backImageUrl,
        selfImageUrl,
        status,
        rejectionReason,
        verifiedAt,
        createdAt,
        updatedAt,
      ];
}
