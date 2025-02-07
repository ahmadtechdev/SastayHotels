import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TourController extends GetxController {
  // Observable properties
  var selectedCar = ''.obs;
  var carPrice = 0.obs;
  var ticketPrice = 0.obs;
  var totalPrice = 0.obs;
  final Rx<DateTime> departureDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().add(const Duration(days:1)).obs;
  // Controllers for each text field
  


  // Update car selection and its price
  void updateCarPrice(String carType, int price) {
    selectedCar.value = carType;
    carPrice.value = price;
    calculateTotalPrice();
  }

  // Update ticket price based on adults and children count
  void updateTicketPrice(
      int adults, int children, int adultPrice, int childPrice) {
    ticketPrice.value = (adults * adultPrice) + (children * childPrice);
    calculateTotalPrice();
  }

  // Calculate total price (ticket + car)
  void calculateTotalPrice() {
    totalPrice.value = ticketPrice.value + carPrice.value;
  }
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var cityController = TextEditingController();

  // Checkboxes
  
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
