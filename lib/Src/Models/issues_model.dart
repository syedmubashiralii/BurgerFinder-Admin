class IssueModel {
  final String id;
  final String name;
  final String email;
  final String issue;
  final DateTime date;

  IssueModel({
    required this.id,
    required this.name,
    required this.email,
    required this.issue,
    required this.date,
  });

  factory IssueModel.fromFirestore(Map<String, dynamic> data, String id) {
    return IssueModel(
      id: id,
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      issue: data['issue'] ?? 'No Issue',
      date: DateTime.parse(data['date']),
    );
  }
}
