import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_user_admin/Src/Controllers/home_controller.dart';
import 'package:restaurant_user_admin/Src/Controllers/notification_controller.dart';
import 'package:restaurant_user_admin/Src/Views/all_promo_codes.dart';
import 'package:restaurant_user_admin/Src/Views/all_issues_list.dart';
import 'package:restaurant_user_admin/Src/Views/all_suggestions_list.dart';
import 'package:restaurant_user_admin/Src/Views/restaurant_list_view.dart';
import 'package:restaurant_user_admin/Src/Views/landing_view.dart';
import 'package:restaurant_user_admin/Src/Views/notification_template.dart';
import 'package:restaurant_user_admin/Src/Views/users_list_screen.dart';
import 'package:restaurant_user_admin/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(message.notification?.toMap().toString());
  await Firebase.initializeApp();
  NotificationService().showSimpleAlertDialog(navigator!.context,
      message.notification?.title ?? "", message.notification?.body ?? "");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HomeController controller = Get.put(HomeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Define the routes
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BurgerFinder Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/menu',

      // Define the routes and associate them with views
      getPages: [
        GetPage(name: '/menu', page: () => const LandingView()),
        GetPage(
            name: '/restaurants', page: () => const RestaurantsListScreen()),
        GetPage(name: '/users', page: () => UserListScreen()),
        GetPage(
            name: '/notification_template', page: () => NotificationTemplate()),
        GetPage(name: '/issues', page: () => AllIssuesList()),
        GetPage(name: '/suggestions', page: () => AllSuggestionsList()),
        GetPage(name: '/promo-codes', page: () => AllPromoCodes()),
      ],
    );
  }
}
