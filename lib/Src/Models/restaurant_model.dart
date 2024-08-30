import 'package:restaurant_user_admin/Src/Models/review_model.dart';

class Restaurant {
  final String id;
  final String description;
  final String image;
  final String location;
  final String name;
  final String ratings;
  final List<Review> reviews;

  Restaurant({
    required this.description,
    required this.id,
    required this.image,
    required this.location,
    required this.name,
    required this.ratings,
    required this.reviews,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      location: map['location'] ?? '',
      name: map['name'] ?? '',
      ratings: map['ratings'] ?? '',
      reviews: (map['review'] as List).map((review) => Review.fromMap(review)).toList(),
    );
  }
}