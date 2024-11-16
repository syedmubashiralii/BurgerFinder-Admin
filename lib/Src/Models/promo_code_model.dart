import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCode {
  final String code;
  final String restaurantId;
  final DateTime expiryDate;
  final bool isActive;

  PromoCode({
    required this.code,
    required this.restaurantId,
    required this.expiryDate,
    required this.isActive,
  });

  factory PromoCode.fromMap(Map<String, dynamic> map) {
    return PromoCode(
      code: map['code'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
    );
  }
}
