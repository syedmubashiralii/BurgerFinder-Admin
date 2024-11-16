import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/notification_controller.dart';

class NotificationTemplate extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
           backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('Notification Template'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter notification title',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Content:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter notification content',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: const ButtonStyle(backgroundColor: const WidgetStatePropertyAll(Colors.teal)),
                onPressed: () async {
                  final notificationService = NotificationService();
                  print('Title: ${titleController.text}');
                  print('Content: ${contentController.text}');
                 await notificationService.broadcastNotificationToAllUsersNew(
                      titleController.text, contentController.text);
                 Get.snackbar("Success", "Notification Sent Succesfully",backgroundColor: Colors.white,colorText: Colors.black);     
                },
                child: const Text('Send Notification',style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
