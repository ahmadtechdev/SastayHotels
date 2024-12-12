import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  final String message;
  final Color backgroundColor;

  CustomSnackBar({
    required this.message,
    required this.backgroundColor,
  });

  void show() {
    Get.snackbar(
      "Sastay Hotels", // Title can be left empty if not needed
      message,
      backgroundColor: backgroundColor,

      colorText: Colors.white, // Text color
      snackPosition: SnackPosition.TOP,
      borderRadius: 22,
      margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
      duration: const Duration(seconds: 3),
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
    );
  }
}
