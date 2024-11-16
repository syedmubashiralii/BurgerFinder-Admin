import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Utils/extensions.dart';
import '../controllers/promo_code_controller.dart';

class AllPromoCodes extends StatelessWidget {
  const AllPromoCodes({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final PromoCodeController controller = Get.put(PromoCodeController());

    // Fetch data when the page loads
    controller.fetchRestaurants();
    controller.fetchPromoCodes();

    // Format the date in a user-friendly format
    String formatDate(DateTime date) {
      return DateFormat('MM/dd/yyyy').format(date);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Codes Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        return Column(
          children: [
            // Display Restaurants Dropdown

            Expanded(
              child: ListView(
                children: [
                  ExpansionTile(
                    title: const Text('Valid Promo Codes'),
                    children: controller.validCodes.map((promo) {
                      // Find the restaurant name based on the restaurantId
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
                        subtitle: Text(
                            'Expires: ${formatDate(promo.expiryDate)}\nRestaurant: ${restaurant.name}'),
                      );
                    }).toList(),
                  ),
                  ExpansionTile(
                    title: const Text('Expired Promo Codes'),
                    children: controller.expiredCodes.map((promo) {
                      // Find the restaurant name based on the restaurantId
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
                        subtitle: Text(
                            'Expired on: ${formatDate(promo.expiryDate)}\nRestaurant: ${restaurant.name}'),
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
                  // Show dialog to create a new promo code
                  _showCreatePromoCodeDialog(context, controller);
                },
                child: const Text('Create New Promo Code'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,foregroundColor: Colors.white),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Function to show a dialog to create a new promo code
  void _showCreatePromoCodeDialog(
      BuildContext context, PromoCodeController controller) {
    final _codeController = TextEditingController();
    final _codeDescriptionController = TextEditingController();
    final _expiryDateController = TextEditingController();

    // Show date picker
    DateTime? selectedDate;

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
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
          title: const Text('Create Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Restaurant>(
                  value: controller.selectedRestaurant.value,
                  hint: const Text('Select Restaurant'),
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  items: controller.restaurants.map((restaurant) {
                    return DropdownMenuItem<Restaurant>(
                      value: restaurant,
                      child: Text(restaurant.name),
                    );
                  }).toList(),
                  onChanged: (restaurant) {
                    controller.selectedRestaurant.value = restaurant;
                  },
                ),
                10.SpaceX,
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Promo Code',border: OutlineInputBorder()),
                ), 10.SpaceX,
                TextFormField(
                  controller: _codeDescriptionController,
                  decoration: const InputDecoration(labelText: 'Promo Description',hintText: 'Enter Promo description to send to users',border: OutlineInputBorder()),
                ), 10.SpaceX,
                TextFormField(
                  controller: _expiryDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'Select Date',border: OutlineInputBorder(),
                    
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

                if (code.isNotEmpty && codeDescription.isNotEmpty && expiryDate != null) {
                  final selectedRestaurantId =
                      controller.selectedRestaurant.value?.id ?? '';
                  if (selectedRestaurantId.isNotEmpty) {
                    Navigator.of(context).pop();
                    controller.createPromoCode(
                        code, codeDescription ,selectedRestaurantId, expiryDate,DateFormat('MM/dd/yyyy').format(expiryDate));
                    
                  } else {
                    Get.snackbar('Error', 'Please select a restaurant first');
                  }
                } else {
                  Get.snackbar('Error', 'Please fill in all fields');
                }
              },
              child: const Text('Create'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
            ),
          ],
        );
      },
    );
  }
}
