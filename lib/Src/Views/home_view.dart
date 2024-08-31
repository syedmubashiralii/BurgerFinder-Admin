import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Models/restaurant_model.dart';
import 'package:restaurant_user_admin/Src/Models/review_model.dart';
import 'package:restaurant_user_admin/Src/Views/add_restaurant_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Home',
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
                ))
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchRestaurants(); // Refresh data
                    Get.snackbar("Refreshed", "Restaurant list updated!",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.teal,
                        colorText: Colors.white);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
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
                        const SizedBox(
                          height: 20,
                        ),
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
  final HomeController controller = Get.find(); // Get the controller instance
  int _currentImageIndex = 0; // Track the current image index for the slider

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
              child: PageView.builder(
                itemCount: widget.restaurant.images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.restaurant.images[index],
                    fit: BoxFit.cover,
                  );
                },
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
                                    .fold(0,
                                        (sum, review) => sum + review.rating);
                                String averageRating = totalVerifiedReviews > 0
                                    ? (sumOfVerifiedRatings /
                                            totalVerifiedReviews)
                                        .toStringAsFixed(
                                            1) // Show average with one decimal
                                    : '0'; // Show 0 if there are no verified reviews
                                return Text(
                                  averageRating,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                );
                              }),
                            ],
                          ),
        ),
        children: [
          if (widget.restaurant.images.isNotEmpty)
            buildImageSlider(), // Build the image slider if images are available
          ...widget.restaurant.reviews.asMap().entries.map((entry) {
            int index = entry.key;
            Review review = entry.value;

            return ListTile(
              isThreeLine: true,
              title: Text(review.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.detail),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating
                            ? Icons.star
                            : Icons.star_border, // Show filled or outlined star
                        color: Colors.amber,
                      );
                    }),
                  )
                ],
              ),
              trailing: review.verified
                  ? const Icon(Icons.verified, color: Colors.green)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined, color: Colors.grey),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            controller.verifyReview(widget.restaurant, index);
                          },
                          child: const Text('Verify'),
                        ),
                      ],
                    ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Method to build the image slider
  Widget buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: widget.restaurant.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.restaurant.images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.restaurant.images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() {
                _currentImageIndex = entry.key;
              }),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Colors.teal
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
