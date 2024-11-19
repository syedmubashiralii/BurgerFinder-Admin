import 'package:cloud_firestore/cloud_firestore.dart';

class PromoCode {
  final String id; 
  final String code;
  final String restaurantId;
  final DateTime expiryDate;
  final bool isActive;
  final List<String> users;
  final DateTime createdAt;

  PromoCode({
    required this.id,
    required this.code,
    required this.restaurantId,
    required this.expiryDate,
    required this.isActive,
    required this.users,
    required this.createdAt,
  });

  /// Factory constructor to create an instance of PromoCode from a Firestore map
  factory PromoCode.fromMap(Map<String, dynamic> map) {
    return PromoCode(
      id: map['id'], // Assign document ID
      code: map['code'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      users: List<String>.from(map['users'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'restaurantId': restaurantId,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'users': users,
      'createdAt': createdAt,
    };
  }
}
