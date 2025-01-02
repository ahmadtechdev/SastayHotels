import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  // Controllers for each text field
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var cityController = TextEditingController();

  // Checkboxes
  var isGroundFloor = false.obs;
  var isHighFloor = false.obs;
  var isLateCheckout = false.obs;
  var isEarlyCheckin = false.obs;
  var isTwinBed = false.obs;
  var isSmoking = false.obs;

  @override
  void onClose() {
    // Dispose controllers
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
