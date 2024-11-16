import 'dart:convert';
import 'dart:math';
// import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/firestore/v1.dart';

class NotificationService {
  final String projectId = 'ordrz-app';
  Future<void> listenNotifications() async {
    FirebaseMessaging.onMessage.listen(_showFlutterNotification);
  }

  var messaging = FirebaseMessaging.instance;

  Future<void> subscribeToAdminTopic() async {
    String token = await getToken();
    String accessToken = await getAccessToken();
    // js.context.callMethod('subscribeToTopic', ['admin', token,accessToken]);
  }

  // Unsubscribe from a topic
  void unsubscribeFromAdminTopic() async {
    String token = await getToken();
    String accessToken = await getAccessToken();
    // js.context.callMethod('unsubscribeFromTopic', ['admin',token,accessToken]);
  }

  void _showFlutterNotification(RemoteMessage message) {
    print(message.toMap().toString());
    RemoteNotification? notification = message.notification;
    showSimpleAlertDialog(navigator!.context, notification?.title ?? "",
        notification?.body ?? "");

    // Feel free to add UI according to your preference, I am just using a custom Toast.
  }

  void showSimpleAlertDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> getToken() async {
    print("enter 1");
    return await FirebaseMessaging.instance.getToken() ?? '';
  }

  // Future<void> saveTokenToDatabase(String token) async {
  //   await FirebaseFirestore.instance.collection('admin').add({
  //     'fcmToken': token,
  //   });
  // }

  getAccessToken() async {
    final credentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "ordrz-app",
      "private_key_id": "21836a6749f12994520130fd8e4052e52a564551",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQClWdw4WechhBhd\nhAnTPM8D2ReCEGBIxWUX2RrCpAEVscciO8w4QxJvJNu8QGO0QlWyRn0rZ8cHufr3\nbVh/CfoBXqj0BvBeQsvjwLfvEreXqE7E3YOToVlte92ty68Rsb4x7jzc2FSEz7Wk\nVH5/XxJ0uNjp7Otmz6r7S3tO+D7u1Qtpg1ZbOFrLhUCpofewL7suxzCwgox5NzWR\nDfqj2ZcAogQYyLT+8oDboplcppnYgNBkTsJfCXLtQZ4859GUi7zvqVZ1vxXj3MLJ\nLk9KfCnWR5e5r1LVFsKgRF84mr5S/6Zn1IwU5P4KO6cWlM9vlhU7bfZLtO8SEVi7\nDJd1vQr7AgMBAAECggEAGsWsbEFTii/cTr6TZVeKAIpUuJM/NmPORP4QIPtd+O3C\ncM60IliVx6zKQ+DnDnzTvvGT0FnVYMZiQKU8jWvc8KjWJpYTCCgSNsucMcIwO1wd\nzi6Rixng+WLzVxxMucreITEnkJhu7YbArHKefVq0NHWTcCNopUpdhEz0klThF66L\nW1ryMMBOVnlN00EgJJudOTtMGWN9EcWf1cfoItmhda1Zs+OcDudeb6tGqTYjj+4d\nj9fJ7zFBUH6w8l5v1Osst8PjtOVphnrUk6aO3GC+R7p3E71N45O0DXMHSaCr58+c\nqOR5Lb5FTpVjOfx1DmZ8GdEFj09o4Ti7K5dO5COcNQKBgQDQoT323j9J5Q+6kHI7\na8pIuJ2GRiph0IHOmzNH0j7EcfDMKG0QoZQLysBjQ33GbblT5ERFMh2h2SB16OYx\nGE4b+/goFsiLSmQ4u2PKfAryurNWeBYFkg66uLsPLBJiYNB82M98RVbwusTg/zwO\nODdmcUCBWxqKKzvkPWi5eaMvnQKBgQDK5QFWgTP4agMdBKs8iXcp0Lahlsof5IsU\nVCWolVY31TxhqIEuwagSeNftBsCkJT7EZCbE+0Y4C1wY/KSAZNCP3EWMv0Twb5q/\ndtequrFnzDluVoCgV0lbDKS82fA6D+kVGJm1oNplYVDxBo8Wo+KvgZnbFE9DPlB3\nNpU5Lje9dwKBgBvYWXfYg+Pt8aJ54vUxVsdL9KJWPRPfC2Qy7K46TmxTtMra3muo\n1SSZxAG7oU7ZmDGtNrtxi+jtHNr/4bFNyCcOAzn+iHemzyePQytkUOXCq2rwDihi\nLRsYysakoDOHLmxrV44Dhy4MD3jkN/TB5gsDNJPPQASO7qhw1chjhrc1AoGAend8\nNUDLo9gphOx6h5HaEa1fb23bFyEWKfEYwgdSAWV+itvxDc3qqyux+eongWzR1C03\nkZKyMcX5k0N779vqX8tvV6Nj81UKLSOIzg7eYm7NA6LHBQFqz8Bz92H9NK7B2+/7\nZ7xt1t/EwZdZ6yqE+7bYrXo21bnZS/vwWpFhJ8UCgYBo7xdbJIOXjBj/3MGwmsmV\nNypGmCpbXBhlERAIy94xuX993dYX36DCfq4UyRbTQcZs8EeeK1gX0kQ+7TFCtJPM\nriPpNCOGqDVXWDXYoCMs/SYfW8m2JIw8KaL/gtzvC3y8eb5E4VS5j7n2mj6h7s3d\nZjnZsn1y7SYyJSRiDc9PYg==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "restaurant-notification-accoun@ordrz-app.iam.gserviceaccount.com",
      "client_id": "108062985780272443733",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/restaurant-notification-accoun%40ordrz-app.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });

    // Obtain an OAuth2 token
    final client = await clientViaServiceAccount(
        credentials, [FirestoreApi.cloudPlatformScope]);
    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }

  Future<void> broadcastNotificationToAllUsersNew(
      String title, String body) async {
    try {
      // Load the service account key JSON file
      // final serviceAccountKey = File(serviceAccountKeyPath).readAsStringSync();

      String accessToken = await getAccessToken();
      // Construct the FCM HTTP v1 API URL
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // Prepare the request payload
      final Map<String, dynamic> payload = {
        'message': {
          'topic':
              'users', // Use 'topic' if you want to send to all users subscribed to a topic
          'notification': {
            'title': title,
            'body': body,
          },
        },
      };

      // Send the notification
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print(response.body.toString());
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': title,
          'message': body,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Broadcast notification sent to all users');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending broadcast notification: $e');
    }
  }
}
