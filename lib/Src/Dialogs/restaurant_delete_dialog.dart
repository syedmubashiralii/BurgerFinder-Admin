  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';

void showDeleteConfirmationDialog(Restaurant restaurant,HomeController controller) {
    Get.defaultDialog(
      title: "Delete Restaurant",
      content: const Text("Are you sure you want to delete this restaurant?"),
      confirm: TextButton(
        onPressed: () {
          controller.deleteRestaurant(restaurant);
          Get.back();
        },
        child: const Text("Yes", style: TextStyle(color: Colors.red)),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text("No"),
      ),
    );
  }