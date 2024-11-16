import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_user_admin/Src/Models/suggestion_model.dart';


class AllSuggestionsList extends StatelessWidget {
  const AllSuggestionsList({super.key});

  Stream<List<SuggestionModel>> _fetchSuggestions() {
    return FirebaseFirestore.instance
        .collection('suggestions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return SuggestionModel.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Suggestions'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<SuggestionModel>>(
        stream: _fetchSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No suggestions found.'));
          }

          final suggestions = snapshot.data!;

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      suggestion.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(suggestion.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${suggestion.email}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      if (suggestion.restaurant.isNotEmpty)
                      Text('Restaurant: ${suggestion.restaurant}'),
                      const SizedBox(height: 4),
                      Text('Suggestion: ${suggestion.suggestion}'),
                      const SizedBox(height: 4),
                      if (suggestion.location.isNotEmpty)
                        Text('Location: ${suggestion.location}', style: const TextStyle(color: Colors.grey)),
                      Text(
                        'Date: ${suggestion.date.toLocal()}'.split('.')[0],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
