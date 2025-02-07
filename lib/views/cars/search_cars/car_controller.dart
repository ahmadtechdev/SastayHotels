import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarController extends GetxController {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var cityController = TextEditingController();
  var pickupController = TextEditingController();
  var offController = TextEditingController();
  final Rx<DateTime> departureDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().add(const Duration(days:1)).obs;


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
  void updateDepartureDate(DateTime newDate) {
    departureDate.value = newDate;

    // If return date is before or equal to new departure date,
    // automatically set it to departure date + 1 day
    if (returnDate.value.isBefore(newDate.add(const Duration(days: 1)))) {
      returnDate.value = newDate.add(const Duration(days: 1));
    }
  }
}
