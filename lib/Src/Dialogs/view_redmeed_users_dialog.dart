import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Models/user_model.dart';

void showRedemeedUsersDialog(BuildContext context, List<String> userIds) {
  if (userIds.isEmpty) {
    Get.snackbar("Info", "No users have redeemed this promo code.");
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Users Redeemed This Code",style: TextStyle(fontSize: 16),),
        content: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where('uid', whereIn: userIds)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 50,
                child: const Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No users redeemed this code.');
            }

            final users = snapshot.data!.docs.map((doc) {
              return UserModel.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: users.map((user) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profileImageUrl != null &&
                                user.profileImageUrl!.isNotEmpty
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null ||
                                user.profileImageUrl!.isEmpty
                            ? Text(
                                user.name != null && user.name!.isNotEmpty
                                    ? user.name![0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text(user.name ?? 'Unknown User'),
                      subtitle:
                          Text(user.email ?? 'No email available'),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
