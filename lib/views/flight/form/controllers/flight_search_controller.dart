import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../services/api_service_flight.dart';
import '../../../../../../widgets/colors.dart';
import '../../../../../../widgets/snackbar.dart';

import '../../search_flights/search_flight_utils/flight_controller.dart';
import '../../search_flights/search_flights.dart';
import 'flight_date_controller.dart';
import '../travelers/traveler_controller.dart';

class FlightSearchController extends GetxController {
  final apiServiceFlight = Get.put(ApiServiceFlight());
  final travelersController = Get.put(TravelersController());
  final flightDateController = Get.put(FlightDateController());
  final flightController = Get.put(FlightController());


  // Observable variables for origin, destination, and trip type
  var origins = RxList<String>([]);
  var destinations = RxList<String>([]);
  var currentTripType = 0.obs; // 0: one-way, 1: return, 2: multi-city

  var isLoading = false.obs;
  var searchResults = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  // Getter for formatted origins string
  String get formattedOrigins =>
      origins.isNotEmpty ? ',${origins.join(',')}' : '';

  // Getter for formatted destinations string
  String get formattedDestinations =>
      destinations.isNotEmpty ? ',${destinations.join(',')}' : '';

  // Method to update origins and destinations
  void updateRoute(int index,
      {String? origin,
        String? destination,
        String? originName,
        String? destinationName}) {
    // Handle origin update
    if (origin != null) {
      // Ensure the origins list has enough elements
      while (index >= origins.length) {
        origins.add('');
      }
      origins[index] = origin;

      // If we're in multi-city mode, update the UI display as well
      if (flightDateController.tripType.value == 'Multi City' &&
          index < flightDateController.flights.length) {
        // Use the originName if provided, otherwise use the code
        String cityDisplay = originName ?? origin;
        flightDateController.flights[index]['origin'] = cityDisplay;
      }
    }

    // Handle destination update
    if (destination != null) {
      // Ensure the destinations list has enough elements
      while (index >= destinations.length) {
        destinations.add('');
      }
      destinations[index] = destination;

      // If we're in multi-city mode, update the UI display
      if (flightDateController.tripType.value == 'Multi City' &&
          index < flightDateController.flights.length) {
        // Use the destinationName if provided, otherwise use the code
        String cityDisplay = destinationName ?? destination;
        flightDateController.flights[index]['destination'] = cityDisplay;

        // Auto-populate next flight's origin if there is one
        if (index + 1 < flightDateController.flights.length) {
          flightDateController.flights[index + 1]['origin'] = cityDisplay;

          // Also ensure the origins array is updated
          if (index + 1 >= origins.length) {
            origins.add(destination);
          } else {
            origins[index + 1] = destination;
          }

          // Notify that the data has changed
          flightDateController.update();
        }
      }
    }

    // Debug print to see current values
    print('Origins: $origins');
    print('Destinations: $destinations');
    print('FlightDateController flights: ${flightDateController.flights}');
  }

  // Method to update trip type
  void updateTripType(String type) {
    switch (type) {
      case 'One-way':
        currentTripType.value = 0;
        break;
      case 'Return':
        currentTripType.value = 1;
        break;
      case 'Multi City':
        currentTripType.value = 2;
        break;
      default:
        currentTripType.value = 0;
    }
  }

  // Method to clear routes
  void clearRoutes() {
    origins.clear();
    destinations.clear();
  }

  Future<void> searchFlights() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Starting flight search...');

      // Update trip type based on flightDateController
      updateTripType(flightDateController.tripType.value);

      // Check if origin and destination are empty before proceeding
      if (origins.isEmpty || destinations.isEmpty) {
        // Show snackbar with error message
        CustomSnackBar(
            message: 'Please select both departure and destination cities',
            backgroundColor: TColors.third)
            .show();

        errorMessage.value =
        'Please select both departure and destination cities';
        isLoading.value = false;
        return;
      }

      // Format dates based on trip type
      String formattedDates = '';

      if (currentTripType.value == 2) {
        // For multi-city trips
        final flights = flightDateController.flights;

        // Make sure we have cities selected for all flights
        if (origins.length < flights.length ||
            destinations.length < flights.length) {
          CustomSnackBar(
              message: 'Please select all departure and destination cities',
              backgroundColor: TColors.third)
              .show();

          errorMessage.value =
          'Please select all departure and destination cities';
          isLoading.value = false;
          return;
        }

        // Format the dates for each flight
        for (int i = 0; i < flights.length; i++) {
          if (i > 0) {
            formattedDates += ',';
          } else {
            formattedDates += ',';
          }
          formattedDates += _formatDate(flights[i]['date']);
        }
      } else {
        // Handle one-way and return trips
        formattedDates =
        ',${_formatDate(flightDateController.departureDate.value)}';

        if (currentTripType.value == 1) {
          formattedDates +=
          ',${_formatDate(flightDateController.returnDate.value)}';
        }
      }

      print('Search parameters:');
      print('Trip type: ${currentTripType.value}');
      print('Origins: $formattedOrigins');
      print('Destinations: $formattedDestinations');
      print('Dates: $formattedDates');
      print('Adults: ${travelersController.adultCount.value}');
      print('Cabin: ${travelersController.travelClass.value}');

      final results = await apiServiceFlight.searchFlights(
        type: currentTripType.value,
        origin: formattedOrigins,
        destination: formattedDestinations,
        depDate: formattedDates,
        adult: travelersController.adultCount.value,
        child: travelersController.childrenCount.value,
        infant: travelersController.infantCount.value,
        stop: 2,
        cabin: travelersController.travelClass.value.toUpperCase(),
      );

      print('API response received:');
      print(results);

      searchResults.value = results;
      flightController.loadFlights(results);
      print('Flight search completed successfully');

      // Navigate based on trip type
      Get.to(() => FlightBookingPage(
          scenario: currentTripType.value == 1
              ? FlightScenario.returnFlight
              : (currentTripType.value == 2
              ? FlightScenario.multiCity
              : FlightScenario.oneWay)));
    } catch (e, stackTrace) {
      print('Error in searchFlights: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Error searching flights: $e';

      Get.snackbar(
        'Error',
        'Error searching flights: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        borderRadius: 10,
        icon: const Icon(Icons.error, color: Colors.white),
      );

      searchResults.value = null;
      flightController.loadFlights({
        'groupedItineraryResponse': {'scheduleDescs': [], 'itineraryGroups': []}
      });
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    // Clear data when the controller is closed to prevent data leaks
    origins.clear();
    destinations.clear();
    super.onClose();
  }
}