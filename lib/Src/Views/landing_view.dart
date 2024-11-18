import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Utils/color_helper.dart';
import 'package:restaurant_user_admin/Src/Views/restaurant_list_view.dart';
import 'package:restaurant_user_admin/Src/Views/notification_template.dart';
import 'package:restaurant_user_admin/Src/Views/users_list_screen.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  // Reusable method to create each action button
  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, String destination) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Get.toNamed(destination);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(colors: [
              Color(0xffB0BEC5),
              AppColors.appBarColor,
            ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 5),
              Text(
                label,textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
    
        backgroundColor: AppColors.primaryColor,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SizedBox(
              width: Get.width>900 ? screenWidth / 2 : screenWidth,
              child: ListView(
                children: [
                  Image.asset("assets/icon-transparent-bg.png", height: 250),
                  const SizedBox(height: 100),
                  Row(
                    children: [
                      _buildActionButton(context, "Restaurants",
                          Icons.restaurant, '/restaurants'),
                      const SizedBox(width: 15),
                      _buildActionButton(
                          context, "Users", Icons.person, '/users'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildActionButton(
                        context,
                        "Notification Template",
                        Icons.notifications,
                        '/notification_template',
                      ),
                      const SizedBox(width: 15),
                      _buildActionButton(
                          context, "Issues", Icons.bug_report, '/issues'),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildActionButton(
                        context,
                        "Suggestions",
                        Icons.settings_suggest,
                        '/suggestions',
                      ),
                       const SizedBox(width: 15),
                      _buildActionButton(
                          context, "Promo Codes", Icons.card_giftcard, '/promo-codes'),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
