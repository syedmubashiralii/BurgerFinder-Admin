import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_user_admin/Src/Controllers/notification_controller.dart';
import 'package:restaurant_user_admin/Src/Dialogs/loading_dialog.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Models/user_model.dart';
import 'package:restaurant_user_admin/Src/Utils/helper_functions.dart';

class HomeController extends GetxController {
  RxList<Restaurant> restaurants = <Restaurant>[].obs;
  RxList<String> imagePaths = <String>[].obs;
  RxList<String> imageUrls = <String>[].obs;
  var restaurantKey = GlobalKey<FormState>();
  final notificationService = NotificationService();
  var users = <UserModel>[].obs;

  @override
  void onInit() {
    fetchRestaurants();
    fetchAllUsers();
    notificationService.subscribeToAdminTopic();
    notificationService.listenNotifications();

    notificationService.getToken().then((v) {
      print("token ${v}");
    });
    super.onInit();
  }

  Future fetchRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();
      restaurants.value =
          snapshot.docs.map((doc) => Restaurant.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }

  void deleteRestaurant(Restaurant restaurant) async {
    try {
      await FirebaseFirestore.instance
          .collection('Restaurants')
          .doc(restaurant.id)
          .delete();
      restaurants.remove(restaurant);
      Get.snackbar("Deleted", "Restaurant deleted successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.teal,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete restaurant: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  void addRestaurant(
      String name,
      String description,
      String location,
      String ratings,
      List<Map<String, dynamic>> menu,
      File? profileImage) async {
    try {
      imageUrls.clear();
      if (restaurantKey.currentState?.validate() ?? false) {
        if (imagePaths.isEmpty) {
          Get.snackbar("Error", "At least one image is required");
          return;
        }
        if (profileImage == null) {
          Get.snackbar("Error", "Add Profile Picture");
          return;
        }

        Get.dialog(
            const Center(child: CircularProgressIndicator(color: Colors.white)),
            barrierDismissible: false);

        await uploadImages();

        DocumentReference docRef =
            FirebaseFirestore.instance.collection('Restaurants').doc();
        String restaurantId = docRef.id;

        await docRef.set({
          'id': restaurantId,
          'name': name,
          'description': description,
          'images': imageUrls,
          'location': location,
          'ratings': ratings,
          'menu': menu,
          'review': [],
          'profilePicture': await uploadProfile(profileImage.path)
        });

        notificationService.broadcastNotificationToAllUsersNew(
            name, "New Restaurant Named ${name} has been added");

        Get.back();
        Get.back();
        fetchRestaurants();
      }
    } catch (e) {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      print('Error adding restaurant: $e');
    }
  }

  Future<void> updateRestaurant(
      String id,
      String name,
      String description,
      String location,
      String ratings,
      List<Map<String, dynamic>> menu,
      File? profileImage) async {
    try {
      imageUrls.clear();
      if (restaurantKey.currentState?.validate() ?? false) {
        if (imagePaths.isEmpty) {
          Get.snackbar("Error", "At least one image is required");
          return;
        }

        if (profileImage == null) {
          Get.snackbar("Error", "Add Profile Picture");
          return;
        }
        Get.dialog(
            const Center(child: CircularProgressIndicator(color: Colors.white)),
            barrierDismissible: false);

        String profileImageUrl = '';
        if (profileImage != null) {
          profileImageUrl = await uploadProfile(profileImage.path);
        }

        await uploadImages();

        await FirebaseFirestore.instance
            .collection('Restaurants')
            .doc(id)
            .update({
          'name': name,
          'description': description,
          'location': location,
          'ratings': ratings,
          'menu': menu,
          'profilePicture': profileImageUrl.isNotEmpty ? profileImageUrl : '',
          'images': imageUrls,
        });
        Get.back();
        Get.back();
        fetchRestaurants();
        Get.snackbar("Success", "Restaurant updated successfully",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.teal,
            colorText: Colors.white);
      }
    } catch (e) {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      print('Error updating restaurant: $e');
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

  Future<void> deleteReview(
      BuildContext context, Restaurant restaurant, int reviewIndex) async {
    try {
      bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Review'),
            content: Text('Are you sure you want to delete this review?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete'),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true) {
        final restaurantRef = FirebaseFirestore.instance
            .collection('Restaurants')
            .doc(restaurant.id);
        restaurant.reviews.removeAt(reviewIndex);
        await restaurantRef.update({
          'review': restaurant.reviews.map((review) => review.toMap()).toList(),
        });
        restaurants.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review deleted successfully')));
      }
    } catch (e) {
      print('Error deleting review: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete the review')));
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imagePaths.add(pickedFile.path);
    }
  }

  Future<int?> getApiLevel() async {
    if (kIsWeb) return null;
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      pickImage();
      return;
    }
    int? apiLevel = await getApiLevel();
    if (apiLevel != null) {
      if (apiLevel >= 33) {
        if (await Permission.photos.request().isGranted) {
          pickImage();
        }
      } else {
        if (await Permission.storage.request().isGranted) {
          pickImage();
        }
      }
    }
  }

  Future<void> uploadImages() async {
    try {
      for (String path in imagePaths) {
        if (path.startsWith("http")) {
          imageUrls.add(path);
        } else {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('restaurant_images/$fileName');
          UploadTask uploadTask;
          if (kIsWeb) {
            Uint8List imageData = await XFile(path).readAsBytes();
            uploadTask = storageReference.putData(imageData);
          } else {
            uploadTask = storageReference.putFile(File(path));
          }
          TaskSnapshot taskSnapshot = await uploadTask;
          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
          print('Image uploaded: $downloadUrl');
        }
      }
    } catch (e) {
      print('Error uploading images: $e');
    }
  }

  Future<String> uploadProfile(String path) async {
    try {
      if (path.startsWith("http")) {
        return path;
      }
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('restaurant_images/$fileName');
      UploadTask uploadTask;

      if (kIsWeb) {
        Uint8List imageData = await XFile(path).readAsBytes();
        uploadTask = storageReference.putData(imageData);
      } else {
        uploadTask = storageReference.putFile(File(path));
      }
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e.toString());
      return '';
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      users.clear();
      users.refresh();
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      users.value = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
      users.refresh();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    }
  }

  Future<void> blockUser(String userId, bool? isBlocked) async {
    Get.back();
    try {
      Get.dialog(LoadingDialog(), barrierDismissible: false);
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'isBlocked': isBlocked});
      closeDialog();
      Get.snackbar(
          'Success',
          isBlocked == true
              ? 'User blocked successfully'
              : 'User unblocked successfully');
      fetchAllUsers();
    } catch (e) {
      closeDialog();
      Get.snackbar('Error', 'Failed to perform operation: $e');
    }
  }

  Future<void> downloadEmailList() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    sheet.appendRow([TextCellValue('Email')]);
    for (var user in users) {
      sheet.appendRow([TextCellValue(user.email ?? "")]);
    }
    final bytes = excel.encode();
    final blob = html.Blob([bytes],
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'user_emails.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);

    Get.snackbar('Success', 'Email list downloaded to your device.');
  }
}
