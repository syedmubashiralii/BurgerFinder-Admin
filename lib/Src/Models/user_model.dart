import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? email;
  final String? name;
  final String? nickname;
  final String? phone;
  final String? profileImageUrl;

  UserModel({
     this.uid,
     this.email,
     this.name,
     this.nickname,
     this.phone,
    this.profileImageUrl,
  });

  // Convert a UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a UserModel instance from Firestore data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      nickname: map['nickname'],
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
    );
  }
}
