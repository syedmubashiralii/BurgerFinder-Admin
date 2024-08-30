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
          'Restaurants',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Obx(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Pull Down to Refresh ",style: TextStyle(color: Colors.white),),
                          Icon(Icons.arrow_downward,color: Colors.white,),
                        ],
                      ),
                      SizedBox(height: 20,),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        title: ListTile(
          leading: CircleAvatar(
            child: Image.network(widget.restaurant.image,
                width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(widget.restaurant.name),
          subtitle: Text(widget.restaurant.description),
          trailing: Text('Rating: ${widget.restaurant.ratings}'),
        ),
        children: widget.restaurant.reviews.asMap().entries.map((entry) {
          int index = entry.key;
          Review review = entry.value;

          return ListTile(
            title: Text(review.name),
            subtitle: Text(review.detail),
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
      ),
    );
  }
}
