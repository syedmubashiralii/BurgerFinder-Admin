import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';

class AddRestaurantView extends GetView<HomeController> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ratingsController = TextEditingController();

  AddRestaurantView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.teal,
        title: const Text(
          'Add Restaurant',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: controller.restaurantKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                controller: nameController,
                labelText: 'Restaurant Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                },
              ),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                },
              ),
              const SizedBox(height: 20),
              Obx(() => controller.imagePath.value.isEmpty
                  ? InkWell(
                      onTap: controller.requestPermissions,
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white)),
                        alignment: Alignment.center,
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                              Text(
                                "Add Restaurnat Image",
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Image.file(File(controller.imagePath.value),
                      height: 150, width: 150, fit: BoxFit.cover)),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                controller: locationController,
                labelText: 'Location (latitude, longitude)',
                hintText: "00.00,11.11",
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }

                  // Regular expression for validating latitude and longitude
                  final RegExp latLngRegex =
                      RegExp(r'^-?\d{1,2}\.\d{2},\s*-?\d{1,3}\.\d{2}$');

                  if (!latLngRegex.hasMatch(value)) {
                    return 'Enter a valid location (e.g., 00.00,11.11)';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  controller.addRestaurant(
                    nameController.text,
                    descriptionController.text,
                    locationController.text,
                    ratingsController.text,
                  );
                  
                },
                child: const Text('Add Restaurant',style: TextStyle(color: Colors.teal),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {super.key,
      required this.controller,
      required this.labelText,
      this.validator,
      this.hintText});
  TextEditingController controller = TextEditingController();
  String labelText;
  String? hintText;
  var validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white), // Text color
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? "",
        labelStyle: const TextStyle(color: Colors.white), // Label text color
        enabledBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // White border when enabled
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // White border when focused
        ),
      ),
    );
  }
}
