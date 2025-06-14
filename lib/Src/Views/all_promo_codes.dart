import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:restaurant_user_admin/Src/Dialogs/delete_promo_code_dialog.dart';
import 'package:restaurant_user_admin/Src/Dialogs/view_redmeed_users_dialog.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Models/user_model.dart';
import 'package:restaurant_user_admin/Src/Utils/extensions.dart';
import '../controllers/promo_code_controller.dart';

class AllPromoCodes extends StatelessWidget {
  const AllPromoCodes({super.key});

  @override
  Widget build(BuildContext context) {
    final PromoCodeController controller = Get.put(PromoCodeController());
    controller.fetchRestaurants();
    controller.fetchPromoCodes();
    String formatDate(DateTime date) {
      return DateFormat('MM/dd/yyyy').format(date);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Promo Codes Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: const Text('Valid Promo Codes'),
                    children: controller.validCodes.map((promo) {
                      final restaurant = controller.restaurants.firstWhere(
                        (restaurant) => restaurant.id == promo.restaurantId,
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

                      return ListTile(
                        title: Text(promo.code),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Expires: ${formatDate(promo.expiryDate)}\nRestaurant: ${restaurant.name}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    confirmDeletePromo(context, promo.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white),
                                  child: const Text('Delete Code'),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showRedemeedUsersDialog(
                                        context, promo.users);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white),
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  ExpansionTile(
                    title: const Text('Expired Promo Codes'),
                    children: controller.expiredCodes.map((promo) {
                      final restaurant = controller.restaurants.firstWhere(
                        (restaurant) => restaurant.id == promo.restaurantId,
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

                      return ListTile(
                        title: Text(promo.code),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Expired on: ${formatDate(promo.expiryDate)}\nRestaurant: ${restaurant.name}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    confirmDeletePromo(context, promo.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white),
                                  child: const Text('Delete Code'),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showRedemeedUsersDialog(
                                        context, promo.users);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white),
                                  child: const Text('View'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Button to show dialog to create a new promo code
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showCreatePromoCodeDialog(context, controller);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white),
                child: const Text('Create New Promo Code'),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showCreatePromoCodeDialog(
      BuildContext context, PromoCodeController controller) {
    final _codeController = TextEditingController();
    final _codeDescriptionController = TextEditingController();
    final _expiryDateController = TextEditingController();
    DateTime? selectedDate;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        _expiryDateController.text = DateFormat('MM/dd/yyyy')
            .format(selectedDate!); // format selected date
      }
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Create Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownSearch<Restaurant>(
                  selectedItem: controller.selectedRestaurant.value,
                  popupProps: const PopupProps.dialog(
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(
                        hintText: "Search Restaurant",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    title: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Select a Restaurant'),
                    ),
                  ),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select Restaurant",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  items: controller.restaurants.value,
                  itemAsString: (restaurant) => restaurant.name,
                  onChanged: (restaurant) {
                    controller.selectedRestaurant.value = restaurant;
                  },
                ),
                10.SpaceX,
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                      labelText: 'Promo Code', border: OutlineInputBorder()),
                ),
                10.SpaceX,
                TextFormField(
                  controller: _codeDescriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Promo Description',
                      hintText: 'Enter Promo description to send to users',
                      border: OutlineInputBorder()),
                ),
                10.SpaceX,
                TextFormField(
                  controller: _expiryDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'Select Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
                10.SpaceX,
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _codeController.text;
                final codeDescription = _codeDescriptionController.text;
                final expiryDate = selectedDate;

                if (code.isNotEmpty &&
                    codeDescription.isNotEmpty &&
                    expiryDate != null) {
                  final selectedRestaurantId =
                      controller.selectedRestaurant.value?.id ?? '';
                  final selectedRestaurantName =
                      controller.selectedRestaurant.value?.name ?? '';
                  if (selectedRestaurantId.isNotEmpty) {
                    controller.createPromoCode(
                        code,
                        codeDescription,
                        selectedRestaurantName,
                        selectedRestaurantId,
                        expiryDate,
                        DateFormat('MM/dd/yyyy').format(expiryDate));
                  } else {
                    Get.snackbar('Error', 'Please select a restaurant first');
                  }
                } else {
                  Get.snackbar('Error', 'Please fill in all fields');
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
