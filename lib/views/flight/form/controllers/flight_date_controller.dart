import 'package:get/get.dart';

class FlightDateController extends GetxController {
  // Selected trip type
  final RxString tripType = 'One-way'.obs;

  // For One-way and Return trips
  final Rx<DateTime> departureDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().add(const Duration(days:1)).obs;

  // For Multi-city trips
  final RxList<Map<String, dynamic>> flights = <Map<String, dynamic>>[
    {'date': DateTime.now()},
    {'date': DateTime.now().add(const Duration(days: 1))},
  ].obs;

  // Update trip type and reset dates accordingly
  void updateTripType(String newType) {
    tripType.value = newType;
    if (newType != 'Multi City') {
      // Reset to default dates for One-way and Return
      departureDate.value = DateTime.now();
      returnDate.value = DateTime.now().add(const Duration(days: 1));
    } else {
      // Reset multi-city flights to default
      flights.value = [
        {'date': DateTime.now()},
        {'date': DateTime.now().add(const Duration(days: 1))},
      ];
    }
  }

  // Update departure date and validate return date
  void updateDepartureDate(DateTime newDate) {
    departureDate.value = newDate;

    // If return date is before or equal to new departure date,
    // automatically set it to departure date + 1 day
    if (returnDate.value.isBefore(newDate.add(const Duration(days: 1)))) {
      returnDate.value = newDate.add(const Duration(days: 1));
    }
  }

  // Update return date with validation
  void updateReturnDate(DateTime newDate) {
    // Ensure return date is not before departure date
    if (newDate.isBefore(departureDate.value)) {
      returnDate.value = departureDate.value.add(const Duration(days: 1));
    } else {
      returnDate.value = newDate;
    }
  }

  // Update multi-city flight date
  void updateMultiCityFlightDate(int index, DateTime newDate) {
    if (index < flights.length) {
      final updatedFlight = Map<String, dynamic>.from(flights[index]);
      updatedFlight['date'] = newDate;
      flights[index] = updatedFlight;
    }
  }

  // Add new flight for multi-city
  void addFlight() {
    flights.add({
      'date': DateTime.now(),
      'origin': '',
      'destination': '',
    });
  }

  // Remove flight from multi-city
  void removeFlight(int index) {
    if (flights.length > 2 && index < flights.length) {
      flights.removeAt(index);
    }
  }

  // Get minimum date for return flight selection
  DateTime getMinReturnDate() {
    return departureDate.value;
  }
}