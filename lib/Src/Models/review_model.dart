class Review {
  final String detail;
  final String name;
  bool verified;
  final int rating; // New field for star rating

  Review({
    required this.detail,
    required this.name,
    required this.verified,
    required this.rating, // Include the rating in the constructor
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      detail: map['detail'] ?? '',
      name: map['name'] ?? '',
      verified: map['verified'] ?? false,
      rating: map['rating'] ?? 0, // Read the rating from the map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'detail': detail,
      'name': name,
      'verified': verified,
      'rating': rating, // Include the rating in the map
    };
  }
}
