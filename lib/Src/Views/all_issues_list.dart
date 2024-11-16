import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_user_admin/Src/Models/issues_model.dart';


class AllIssuesList extends StatelessWidget {
  const AllIssuesList({super.key});

  Stream<List<IssueModel>> _fetchIssues() {
    return FirebaseFirestore.instance
        .collection('issues')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return IssueModel.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Issues'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<IssueModel>>(
        stream: _fetchIssues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No issues found.'));
          }

          final issues = snapshot.data!;

          return ListView.builder(
            itemCount: issues.length,
            itemBuilder: (context, index) {
              final issue = issues[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(
                      issue.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(issue.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(issue.issue),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${issue.date.toLocal()}'.split('.')[0],
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
