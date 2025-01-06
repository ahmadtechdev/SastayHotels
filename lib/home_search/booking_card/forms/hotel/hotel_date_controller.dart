import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HotelDateController extends GetxController {
  // Original check-in and check-out date variables (needed for API compatibility)
  final Rx<DateTime> checkInDate = DateTime.now().obs;
  final Rx<DateTime> checkOutDate = DateTime.now().add(const Duration(days: 1)).obs;

  // New date range variable
  final Rx<DateTimeRange> dateRange = Rx<DateTimeRange>(
    DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    ),
  );

  // Nights counter
  final RxInt nights = RxInt(1);

  // Minimum stay duration in days
  static const int minStayDuration = 0;

  @override
  void onInit() {
    super.onInit();
    // Initialize everything to be in sync
    _syncDates();
  }

  // Update date range and sync all date variables
  void updateDateRange(DateTimeRange newRange) {
    dateRange.value = newRange;
    nights.value = newRange.duration.inDays;

    // Update check-in and check-out dates to match the range
    checkInDate.value = newRange.start;
    checkOutDate.value = newRange.end;
  }

  // Update number of nights and adjust dates accordingly
  void updateNights(int newNights) {
    if (newNights > 0) {
      nights.value = newNights;

      // Update date range
      dateRange.value = DateTimeRange(
        start: dateRange.value.start,
        end: dateRange.value.start.add(Duration(days: newNights)),
      );

      // Sync check-in and check-out dates
      checkInDate.value = dateRange.value.start;
      checkOutDate.value = dateRange.value.end;
    }
  }

  // Original check-in date update with new range sync
  void updateCheckInDate(DateTime newCheckInDate) {
    checkInDate.value = newCheckInDate;

    // Calculate new check-out date based on current nights
    DateTime newCheckOutDate = newCheckInDate.add(Duration(days: nights.value));
    checkOutDate.value = newCheckOutDate;

    // Update date range to match
    dateRange.value = DateTimeRange(
      start: newCheckInDate,
      end: newCheckOutDate,
    );
  }

  // Original check-out date update with new range sync
  void updateCheckOutDate(DateTime newCheckOutDate) {
    // Ensure check-out date is not before check-in date + minimum stay
    final DateTime minimumCheckOutDate = checkInDate.value.add(const Duration(days: minStayDuration));

    if (newCheckOutDate.isBefore(minimumCheckOutDate)) {
      checkOutDate.value = minimumCheckOutDate;
    } else {
      checkOutDate.value = newCheckOutDate;
    }

    // Update date range and nights
    dateRange.value = DateTimeRange(
      start: checkInDate.value,
      end: checkOutDate.value,
    );
    nights.value = dateRange.value.duration.inDays;
  }

  // Helper method to sync all date-related variables
  void _syncDates() {
    // Ensure check-in/check-out dates match date range
    checkInDate.value = dateRange.value.start;
    checkOutDate.value = dateRange.value.end;
    nights.value = dateRange.value.duration.inDays;
  }

  // Convenience methods for adjusting nights
  void incrementNights() {
    updateNights(nights.value + 1);
  }

  void decrementNights() {
    if (nights.value > 1) {
      updateNights(nights.value - 1);
    }
  }

  // Get the minimum selectable date for check-out based on selected check-in date
  DateTime getMinCheckOutDate() {
    return checkInDate.value.add(const Duration(days: minStayDuration));
  }
}