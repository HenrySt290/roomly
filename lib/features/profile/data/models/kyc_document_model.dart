import 'package:roomly/features/profile/domain/entities/export.dart';

class KycDocumentModel extends KycDocumentEntity {
  const KycDocumentModel({
    required super.id,
    required super.userId,
    required super.documentType,
    required super.documentUrl,
    super.frontImageUrl,
    super.backImageUrl,
    super.selfImageUrl,
    super.status,
    super.rejectionReason,
    super.verifiedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory KycDocumentModel.fromJson(Map<String, dynamic> json) {
    return KycDocumentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      documentType: json['document_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
      frontImageUrl: json['front_image_url'],
      backImageUrl: json['back_image_url'],
      selfImageUrl: json['self_image_url'],
      status: KYCStatus.values.firstWhere(
        (e) => e.toString() == 'KYCStatus.${json['status']}',
        orElse: () => KYCStatus.pending,
      ),
      rejectionReason: json['rejection_reason'],
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
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
      'document_type': documentType,
      'document_url': documentUrl,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'self_image_url': selfImageUrl,
      'status': status.toString().split('.').last,
      'rejection_reason': rejectionReason,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  KycDocumentModel copyWith({
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
    return KycDocumentModel(
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
}
