import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Dialogs/restaurant_delete_dialog.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Models/review_model.dart';
import 'package:restaurant_user_admin/Src/Views/add_restaurant_view.dart';
import 'package:restaurant_user_admin/Src/Views/notification_template.dart';
import 'package:restaurant_user_admin/Src/Views/users_list_screen.dart';
import 'package:restaurant_user_admin/Src/Widgets/restaurant_image_slider.dart';

class RestaurantsListScreen extends GetView<HomeController> {
  const RestaurantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'All Restaurants',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Obx(
          () => controller.restaurants.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchRestaurants();
                    Get.snackbar("Refreshed", "Restaurant list updated!",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.teal,
                        colorText: Colors.white);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (!kIsWeb)
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Pull Down to Refresh ",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.restaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant = controller.restaurants[index];
                              return RestaurantTile(restaurant: restaurant);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          controller.imagePaths.clear();
          controller.imageUrls.clear();
          Get.to(() => AddRestaurantView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class RestaurantTile extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantTile({Key? key, required this.restaurant}) : super(key: key);

  @override
  _RestaurantTileState createState() => _RestaurantTileState();
}

class _RestaurantTileState extends State<RestaurantTile> {
  final HomeController controller = Get.find();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        title: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: ClipOval(
              child: Image.network(
                widget.restaurant.profilePicture?.isEmpty ?? true
                    ? widget.restaurant.images[0]
                    : widget.restaurant.profilePicture!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(widget.restaurant.name),
          subtitle: Text(widget.restaurant.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Builder(builder: (context) {
                int totalVerifiedReviews = widget.restaurant.reviews
                    .where((review) => review.verified)
                    .length;
                int sumOfVerifiedRatings = widget.restaurant.reviews
                    .where((review) => review.verified)
                    .fold(0, (sum, review) => sum + review.rating);
                String averageRating = totalVerifiedReviews > 0
                    ? (sumOfVerifiedRatings / totalVerifiedReviews)
                        .toStringAsFixed(1)
                    : '0';
                return Text(
                  averageRating,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              }),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  controller.imagePaths.value = widget.restaurant.images;
                  Get.to(() => AddRestaurantView(),
                      arguments: widget.restaurant);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDeleteConfirmationDialog(widget.restaurant, controller);
                },
              ),
            ],
          ),
        ),
        children: [
          if (widget.restaurant.images.isNotEmpty)
            ImageSlider(restaurant: widget.restaurant),
          ...widget.restaurant.reviews.asMap().entries.map((entry) {
            int index = entry.key;
            Review review = entry.value;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), 
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reviewer Name: ${review.name}",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("Detail: ${review.detail}"),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Value'),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Quality'),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < review.qualityRating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        if (review.images.isNotEmpty)
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: review.images.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Image.network(
                                    review.images[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (review.verified)
                        const Icon(Icons.verified, color: Colors.green)
                      else
                        ElevatedButton(
                          onPressed: () {
                            controller.verifyReview(widget.restaurant, index);
                          },
                          child: const Text('Verify'),
                        ),
                      IconButton(
                        onPressed: () {
                          controller.deleteReview(
                              context, widget.restaurant, index);
                        },
                        icon: const Icon(Icons.delete,color: Colors.red,),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
