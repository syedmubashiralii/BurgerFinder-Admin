class Review {
  final String detail;
  final String name;
  bool verified;
  final int rating; // Field for star rating
  final int qualityRating; // Field for star rating
  List<String> images; // Field to store image URLs

  Review({
    required this.detail,
    required this.name,
    required this.verified,
    required this.rating, // Include the rating in the constructor
    required this.qualityRating,
    required this.images, // Include the images in the constructor
  });

  // Factory constructor to create a Review from a map
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      detail: map['detail'] ?? '',
      name: map['name'] ?? '',
      verified: map['verified'] ?? false,
      rating: map['rating'] ?? 0,
      qualityRating: map['qualityRating'] ?? 0,
      images: List<String>.from(map['images'] ?? []), 
    );
  }

  // Convert the Review instance to a map
  Map<String, dynamic> toMap() {
    return {
      'detail': detail,
      'name': name,
      'verified': verified,
      'rating': rating,
      'qualityRating': qualityRating,
      'images': images, 
    };
  }
}
