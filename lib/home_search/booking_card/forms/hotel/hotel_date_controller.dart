import 'package:get/get.dart';

class HotelDateController extends GetxController {
  final Rx<DateTime> checkInDate = DateTime.now().obs;
  final Rx<DateTime> checkOutDate = DateTime.now().add(const Duration(days: 1)).obs;

  // Minimum stay duration in days
  static const int minStayDuration = 0;

  // Update check-in date and automatically adjust check-out date if needed
  void updateCheckInDate(DateTime newCheckInDate) {
    // Ensure check-in date is not after current check-out date
    checkInDate.value = newCheckInDate;

    // If check-out date is before or equal to new check-in date,
    // automatically set it to check-in date + minimum stay duration
    if (checkOutDate.value.isBefore(newCheckInDate.add(const Duration(days: minStayDuration)))) {
      checkOutDate.value = newCheckInDate.add(const Duration(days: minStayDuration+1));
    }
  }

  // Update check-out date with validation
  void updateCheckOutDate(DateTime newCheckOutDate) {
    // Ensure check-out date is not before check-in date + minimum stay
    final DateTime minimumCheckOutDate = checkInDate.value.add(const Duration(days: minStayDuration));

    if (newCheckOutDate.isBefore(minimumCheckOutDate)) {
      checkOutDate.value = minimumCheckOutDate;
    } else {
      checkOutDate.value = newCheckOutDate;
    }
  }

  // Get the minimum selectable date for check-out based on selected check-in date
  DateTime getMinCheckOutDate() {
    return checkInDate.value.add(const Duration(days: minStayDuration));
  }
}