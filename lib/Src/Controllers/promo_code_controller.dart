import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:restaurant_user_admin/Src/Controllers/notification_controller.dart';
import 'package:restaurant_user_admin/Src/Dialogs/loading_dialog.dart';
import 'package:restaurant_user_admin/Src/Models/promo_code_model.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Models/user_model.dart';
import 'package:restaurant_user_admin/Src/Utils/helper_functions.dart';

class PromoCodeController extends GetxController {
  var redeemedUsers = <UserModel>[].obs;
  var restaurants = <Restaurant>[].obs;
  var promoCodes = <PromoCode>[].obs;
  var validCodes = <PromoCode>[].obs;
  var expiredCodes = <PromoCode>[].obs;
  var selectedRestaurant = Rx<Restaurant?>(null);

  // Fetch restaurants from Firestore
  Future<void> fetchRestaurants() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Restaurants').get();
      restaurants.value =
          snapshot.docs.map((doc) => Restaurant.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching restaurants: $e');
    }
  }

  // Fetch promo codes from Firestore
  Future<void> fetchPromoCodes() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('PromoCodes').get();
      promoCodes.value =
          snapshot.docs.map((doc) => PromoCode.fromMap(doc.data())).toList();
      filterPromoCodes();
    } catch (e) {
      print('Error fetching promo codes: $e');
    }
  }

  Future<void> fetchRedeemedUsers(List<String> userIds) async {
    var usersQuery = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', whereIn: userIds)
        .get();

    redeemedUsers.value =
        usersQuery.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  void filterPromoCodes() {
    final now = DateTime.now();
    validCodes.value = promoCodes
        .where((code) => code.isActive && code.expiryDate.isAfter(now))
        .toList();
    expiredCodes.value = promoCodes
        .where((code) => code.expiryDate.isBefore(now) || !code.isActive)
        .toList();
  }

  Future<void> deletePromoCode(String promoId) async {
    try {
      Get.dialog(LoadingDialog());
      await FirebaseFirestore.instance
          .collection('PromoCodes')
          .doc(promoId)
          .delete();
      closeDialog();
      fetchPromoCodes();
      Get.snackbar('Success', 'Promo Code deleted successfully');
    } catch (e) {
      closeDialog();
      Get.snackbar('Error', 'Failed to delete promo code: $e');
      print('Error deleting promo code: $e');
    }
  }

  // Create a new promo code
  Future<void> createPromoCode(String code, String codeDescription,String restaurantName,
      String restaurantId, DateTime expiryDate, String readAbleDate) async {
    try {
      // Show loading dialog
      Get.dialog(LoadingDialog(), barrierDismissible: false);

      // Check if promo code already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PromoCodes')
          .where('code', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        closeDialog();
        Get.snackbar(
            "Error", "Promo code already exists. Please enter a new code.");
        return;
      }

      // Add promo code to Firestore and get the document reference
      final docRef =
          await FirebaseFirestore.instance.collection('PromoCodes').add({
        'code': code,
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'isActive': true,
        'description': codeDescription,
        'users': [],
        'createdAt': Timestamp.now(),
      });

      // Update the document with its own ID
      await docRef.update({'id': docRef.id});

      // Fetch the associated restaurant
      final restaurant = restaurants.firstWhere(
        (restaurant) => restaurant.id == restaurantId,
        orElse: () => Restaurant(
            id: '',
            name: "Unknown",
            description: '',
            images: [],
            location: '',
            profilePicture: '',
            ratings: '',
            reviews: []),
      );

      // Send notification to all users
      NotificationService().broadcastNotificationToAllUsersNew(
        code,
        "${codeDescription}\n Applicable At: ${restaurant.name} \n Expiry Date: ${readAbleDate}",
      );

      // Refresh promo codes list
      fetchPromoCodes();

      // Close loading dialog and show success message
     
      closeDialog();
       Get.back();
      Get.snackbar("Success", "Promo Code Created");
    } catch (e) {
      closeDialog();
      print('Error creating promo code: $e');
      Get.snackbar("Error", "Error creating promo code: $e");
    }
  }
}
