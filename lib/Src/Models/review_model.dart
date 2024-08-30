class Review {
  final String detail;
  final String name;
  bool verified;

  Review({required this.detail, required this.name, required this.verified});

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      detail: map['detail'] ?? '',
      name: map['name'] ?? '',
      verified: map['verified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail': detail,
      'name': name,
      'verified': verified,
    };
  }
}