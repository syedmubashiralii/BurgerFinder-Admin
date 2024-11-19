import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promo_code_controller.dart';

void confirmDeletePromo(BuildContext context, String promoId) {
  final PromoCodeController controller = Get.find();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this promo code?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deletePromoCode(promoId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
