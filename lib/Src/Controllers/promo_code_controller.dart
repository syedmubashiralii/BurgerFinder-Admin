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

  // Create a new promo code
  Future<void> createPromoCode(String code, String codeDescription,
      String restaurantId, DateTime expiryDate, String readAbleDate) async {
    try {
      Get.dialog(LoadingDialog(), barrierDismissible: false);
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

      await FirebaseFirestore.instance.collection('PromoCodes').add({
        'code': code,
        'restaurantId': restaurantId,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'isActive': true,
        'description': codeDescription,
        'users': []
      });

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

      NotificationService().broadcastNotificationToAllUsersNew(code,
          "${codeDescription}\n Applicable At: ${restaurant.name} \n Expiry Date: ${readAbleDate}");
      fetchPromoCodes();
      closeDialog();
      Get.snackbar("Success", "Promo Code Created");
    } catch (e) {
      closeDialog();
      print('Error creating promo code: $e');
      Get.snackbar("Error", "Error creating promo code: $e");
    }
  }
}
