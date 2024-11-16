import 'package:flutter/material.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';

Future<void> deleteUserDialog(
      BuildContext context, String userId,HomeController userController) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
               
                userController.deleteUser(
                    userId); 
                
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }