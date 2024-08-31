import 'package:restaurant_user_admin/Src/Models/review_model.dart';

class Restaurant {
  final String id;
  final String name;
  final String description;
  final List<String> images; // List to store multiple image URLs
  final String location;
  final String ratings;
  final List<Review> reviews;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.location,
    required this.ratings,
    required this.reviews,
  });

  // From Map method to create a Restaurant instance from a Firestore document
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []), // Convert to List<String>
      location: map['location'] ?? '',
      ratings: map['ratings'] ?? '',
      reviews: (map['review'] as List<dynamic>?)
              ?.map((item) => Review.fromMap(item))
              .toList() ??
          [],
    );
  }

  // To Map method to convert a Restaurant instance to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'images': images, // Keep the images as a list of strings
      'location': location,
      'ratings': ratings,
      'review': reviews.map((review) => review.toMap()).toList(),
    };
  }
}
