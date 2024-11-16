import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_user_admin/Src/Models/user_model.dart';

class PromoCode {
  final String code;
  final String restaurantId;
  final DateTime expiryDate;
  final bool isActive;
  final List<String> users;

  PromoCode({
    required this.code,
    required this.restaurantId,
    required this.expiryDate,
    required this.isActive,
    required this.users, 
  });

  factory PromoCode.fromMap(Map<String, dynamic> map) {
    return PromoCode(
      code: map['code'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      users: List<String>.from(map['users'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'restaurantId': restaurantId,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'users': users, 
    };
  }
}