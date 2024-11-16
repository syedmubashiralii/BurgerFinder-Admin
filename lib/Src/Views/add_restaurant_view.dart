import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Views/location_Picker_View.dart';
import 'package:restaurant_user_admin/Src/Widgets/custom_text_field.dart';



class AddRestaurantView extends StatefulWidget {
  AddRestaurantView({super.key});

  @override
  State<AddRestaurantView> createState() => _AddRestaurantViewState();
}

class _AddRestaurantViewState extends State<AddRestaurantView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ratingsController = TextEditingController();

  final List<TextEditingController> menuItemNameControllers = [];
  final HomeController controller = Get.find();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;

  Restaurant? editingRestaurant;

  @override
  void initState() {
    super.initState();
    editingRestaurant = Get.arguments as Restaurant?;
    if (editingRestaurant != null) {
      nameController.text = editingRestaurant?.name??"";
      descriptionController.text = editingRestaurant?.description??"";
      locationController.text = editingRestaurant?.location??"";
      for (var menuItem in editingRestaurant?.menu??List.empty()) {
        menuItemNameControllers.add(TextEditingController(text: menuItem['name']));
      }
      _profileImage = editingRestaurant!.profilePicture !=''
          ? File(editingRestaurant!.profilePicture)
          : null;
    }
  }

  Future<void> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.teal,
        title: Text(
          editingRestaurant != null ? 'Edit Restaurant' : 'Add Restaurant',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Form(
        key: controller.restaurantKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickProfileImage,
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      shape: BoxShape.circle,
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: kIsWeb
                                ? Image.network(_profileImage!.path)
                                : Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: Colors.white),
                              Text("Add Profile Picture",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: nameController,
                  labelText: 'Restaurant Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                  },
                ),
                const SizedBox(height: 20),
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
                Obx(() {
                  return controller.imagePaths.isEmpty
                      ? InkWell(
                          onTap: controller.requestPermissions,
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                Text("Add Restaurant Images",
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                          ),
                          height: 200,
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.imagePaths.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: kIsWeb
                                          ? Image.network(
                                              controller.imagePaths[index])
                                          : Image.file(
                                              File(controller.imagePaths[index]),
                                              height: 150,
                                              width: 150,
                                              fit: BoxFit.cover,
                                            ),
                                    );
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: controller.requestPermissions,
                                child: const Text('Add Picture',
                                    style: TextStyle(color: Colors.teal)),
                              ),
                            ],
                          ),
                        );
                }),
                const SizedBox(height: 20),
                CustomTextField(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPickerPage(
                          onAddLocation: (location) {
                            locationController.text =
                                '${location.latitude},${location.longitude}';
                          },
                        ),
                      ),
                    );
                  },
                  readOnly: true,
                  controller: locationController,
                  labelText: 'Location (latitude, longitude)',
                  hintText: "00.00,11.11",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Location is required';
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Menu Items',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: menuItemNameControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: menuItemNameControllers[index],
                              labelText: 'Menu Item Name',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              menuItemNameControllers.removeAt(index);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    menuItemNameControllers.add(TextEditingController());
                    setState(() {});
                  },
                  child: const Text('Add Menu Item',
                      style: TextStyle(color: Colors.teal)),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (editingRestaurant != null) {
                      // Update existing restaurant
                      controller.updateRestaurant(
                        editingRestaurant!.id,
                        nameController.text,
                        descriptionController.text,
                        locationController.text,
                        ratingsController.text,
                        getMenuItems(),
                        _profileImage!,
                      );
                    } else {
                      // Add new restaurant
                      controller.addRestaurant(
                        nameController.text,
                        descriptionController.text,
                        locationController.text,
                        ratingsController.text,
                        getMenuItems(),
                        _profileImage!,
                      );
                    }
                  },
                  child: Text(
                    editingRestaurant != null
                        ? 'Update Restaurant'
                        : 'Add Restaurant',
                    style: const TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getMenuItems() {
    List<Map<String, dynamic>> menuItems = [];
    for (int i = 0; i < menuItemNameControllers.length; i++) {
      if (menuItemNameControllers[i].text.isNotEmpty) {
        menuItems.add({
          'name': menuItemNameControllers[i].text,
        });
      }
    }
    return menuItems;
  }
}
