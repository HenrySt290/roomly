import 'package:equatable/equatable.dart';

class AccessPassEntity extends Equatable {
  final int id;
  final int userId;
  final bool isActive;
  final DateTime purchasedAt;
  final DateTime expiresAt;
  final double amount;
  final String paymentStatus; // 'pending', 'success', 'failed'
  final String? transactionId;

  const AccessPassEntity({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.purchasedAt,
    required this.expiresAt,
    required this.amount,
    required this.paymentStatus,
    this.transactionId,
  });

  factory AccessPassEntity.fromJson(Map<String, dynamic> json) {
    return AccessPassEntity(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      isActive: json['is_active'] ?? false,
      purchasedAt: DateTime.parse(json['purchased_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      amount: (json['amount'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'pending',
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'is_active': isActive,
      'purchased_at': purchasedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'amount': amount,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => isActive && !isExpired;
  int get remainingHours => expiresAt.difference(DateTime.now()).inHours;

  @override
  List<Object?> get props => [
        id,
        userId,
        isActive,
        purchasedAt,
        expiresAt,
        amount,
        paymentStatus,
        transactionId,
      ];

  AccessPassEntity copyWith({
    int? id,
    int? userId,
    bool? isActive,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    double? amount,
    String? paymentStatus,
    String? transactionId,
  }) {
    return AccessPassEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      amount: amount ?? this.amount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
