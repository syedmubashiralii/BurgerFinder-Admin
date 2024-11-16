class SuggestionModel {
  final String id;
  final String name;
  final String email;
  final String location;
  final String restaurant;
  final String suggestion;
  final DateTime date;

  SuggestionModel({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    required this.restaurant,
    required this.suggestion,
    required this.date,
  });

  factory SuggestionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SuggestionModel(
      id: id,
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      location: data['location'] ?? 'No Location',
      restaurant: data['restaurant'] ?? 'No Restaurant',
      suggestion: data['suggestion'] ?? 'No Suggestion',
      date: DateTime.parse(data['date']),
    );
  }
}
