import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeController extends GetxController {
  RxList restaurants = <Restaurant>[].obs;
  var imagePath = ''.obs;
  var imageUrl = ''.obs;
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
      if (imagePath.isEmpty) {
        Get.snackbar("Error", "Image is required");
        return;
      }
      await uploadImage();

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
        'image': imageUrl.value,
        'location': location,
        'ratings': ratings,
        'review': [], // Start with empty reviews
      });

      Get.back();
      fetchRestaurants(); // Refresh the list after adding
    }
  } catch (e) {
    print('Error adding restaurant: $e');
  }
}


  Future<void> verifyReview(Restaurant restaurant, int reviewIndex) async {
    try {
      // Reference to the restaurant document in Firebase
      final restaurantRef = FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurant.id); // Assuming you have an ID field in Restaurant model

      // Update the specific review's verified status to true
      restaurant.reviews[reviewIndex].verified = true;

      await restaurantRef.update({
        'review': restaurant.reviews.map((review) => review.toMap()).toList(),
      });

      // Update the local state
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
      imagePath.value = pickedFile.path;
    }
  }

  Future<int?> getApiLevel() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt; // API level of the Android device
  }

  Future<void> requestPermissions() async {
    int? apiLevel = await getApiLevel();
    if (apiLevel != null) {
      if (apiLevel >= 33) {
        // Android 13+
        if (await Permission.photos.request().isGranted) {
          pickImage();
          // Handle denied access
        }
      } else {
        // Android versions below 13
        if (await Permission.storage.request().isGranted) {
          pickImage();
          // Handle denied access
        }
      }
    }
  }

  Future<void> uploadImage() async {
    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('restaurant_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(File(imagePath.value));

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      imageUrl.value = downloadUrl; // Store image URL
      print('Image uploaded: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
