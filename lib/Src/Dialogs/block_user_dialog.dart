import 'package:flutter/material.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';

Future<void> blockUserDialog(BuildContext context, String userId,
    HomeController userController, bool? isBlocked) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(isBlocked == true ? 'Confirm Unblock' : 'Confirm Block'),
        content: Text(isBlocked == true
            ? 'Are you sure you want to unblock this user?'
            : 'Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () {
              userController.blockUser(
                  userId, isBlocked == true ? false : true);
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
