import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DateController extends GetxController {
  // Observable Dates
  var checkInDate = DateTime.now().obs; // Default Check-In date
  var checkOutDate = DateTime.now().add(Duration(days: 1)).obs; // Default Check-Out date

  // Method to update Check-In Date
  void updateCheckInDate(DateTime newDate) {
    checkInDate.value = newDate;

    // Auto-adjust Check-Out date if it becomes invalid
    if (checkOutDate.value.isBefore(newDate)) {
      checkOutDate.value = newDate.add(Duration(days: 1));
    }
  }

  // Method to update Check-Out Date
  void updateCheckOutDate(DateTime newDate) {
    checkOutDate.value = newDate;

    // Auto-adjust Check-In date if it becomes invalid
    if (checkInDate.value.isAfter(newDate)) {
      checkInDate.value = newDate.subtract(Duration(days: 1));
    }
  }
}