import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';

class HomeController extends GetxController {
  RxList<Restaurant> restaurants = <Restaurant>[].obs;
  RxList<String> imagePaths = <String>[].obs; // List to store multiple image paths
  RxList<String> imageUrls = <String>[].obs; // List to store multiple image URLs
  var restaurantKey = GlobalKey<FormState>();

  @override
  void onInit() {
    fetchRestaurants();
    super.onInit();
  }

  fetchRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();
      restaurants.value =
          snapshot.docs.map((doc) => Restaurant.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }

  void addRestaurant(
  String name, String description, String location, String ratings) async {
  try {
    if (restaurantKey.currentState?.validate() ?? false) {
      if (imagePaths.isEmpty) {
        Get.snackbar("Error", "At least one image is required");
        return;
      }

      // Show loading dialog
      Get.dialog(
        Center(
          child: CircularProgressIndicator(color: Colors.white,),
        ),
        barrierDismissible: false, // Prevents dialog from being dismissed by tapping outside
      );

      await uploadImages(); // Upload all images

      // Create a new document reference in Firestore
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Restaurants').doc();

      // Use the document ID as the unique ID
      String restaurantId = docRef.id;

      // Add the restaurant data to Firestore with the unique ID
      await docRef.set({
        'id': restaurantId, // Include the generated document ID
        'name': name,
        'description': description,
        'images': imageUrls, // Store all image URLs
        'location': location,
        'ratings': ratings,
        'review': [], // Start with empty reviews
      });

      // Close loading dialog
      Get.back(); // Closes the loading dialog

      Get.back(); // Navigates back to the previous screen
      fetchRestaurants(); // Refresh the list after adding
    }
  } catch (e) {
    // Close loading dialog in case of an error
    if (Get.isDialogOpen == true) {
      Get.back(); // Closes the loading dialog if it's still open
    }
    print('Error adding restaurant: $e');
  }
}

  Future<void> verifyReview(Restaurant restaurant, int reviewIndex) async {
    try {
      final restaurantRef = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurant.id);

      restaurant.reviews[reviewIndex].verified = true;

      await restaurantRef.update({
        'review': restaurant.reviews.map((review) => review.toMap()).toList(),
      });

      restaurants.refresh();
    } catch (e) {
      print('Error verifying review: $e');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imagePaths.add(pickedFile.path); // Add each image path to the list
    }
  }

  Future<int?> getApiLevel() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<void> requestPermissions() async {
    int? apiLevel = await getApiLevel();
    if (apiLevel != null) {
      if (apiLevel >= 33) {
        // Android 13+
        if (await Permission.photos.request().isGranted) {
          pickImage();
        }
      } else {
        // Android versions below 13
        if (await Permission.storage.request().isGranted) {
          pickImage();
        }
      }
    }
  }

  Future<void> uploadImages() async {
    try {
      for (String path in imagePaths) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('restaurant_images/$fileName');
        UploadTask uploadTask = storageReference.putFile(File(path));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        imageUrls.add(downloadUrl); // Add each image URL to the list
        print('Image uploaded: $downloadUrl');
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
  }
}
