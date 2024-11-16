import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Dialogs/delete_user_dialog.dart';
import 'package:restaurant_user_admin/Src/Dialogs/restaurant_delete_dialog.dart';

class UserListScreen extends StatelessWidget {
  final HomeController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('Users'),
        centerTitle: true,
        
      ),
      floatingActionButton: Padding(
            padding: const EdgeInsets.only(right: 10,bottom: 50),
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(Colors.teal),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: const Text(
                "Download Users List",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => userController.downloadEmailList(),
            ),
          ),
      body: Obx(() {
        if (userController.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: userController.users.length,
          itemBuilder: (context, index) {
            final user = userController.users[index];
            return Container(
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black))),
              child: ExpansionTile(
                title: Text(user.name ?? 'Unnamed'),
                children: [
                  ListTile(title: Text('Email: ${user.email}')),
                  ListTile(title: Text('Nickname: ${user.nickname}')),
                  ListTile(title: Text('Phone: ${user.phone}')),
                  if (user.profileImageUrl != null)
                    ListTile(
                      title: const Text('Profile Image:'),
                      subtitle: Image.network(
                        user.profileImageUrl!,
                        height: 100,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      label: const Text('Delete User'),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteUserDialog(context, user.uid ?? "",userController);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  
}
