
import 'package:get/get.dart';
import '../../../../../../services/api_service_flight.dart';

import '../../search_flights/search_flight_utils/flight_controller.dart';
import '../../search_flights/search_flights.dart';
import 'flight_date_controller.dart';
import '../travelers/traveler_controller.dart';

class FlightSearchController extends GetxController {
  final apiServiceFlight = Get.put(ApiServiceFlight());
  final travelersController = Get.put(TravelersController());
  final flightDateController = Get.put(FlightDateController());
  final flightController = Get.put(FlightController());

  // New observable variables for origin, destination, and trip type
  var origins = RxList<String>([]);  // No default value
  var destinations = RxList<String>([]);  // No default value
  var currentTripType = 0.obs; // 0: one-way, 1: return, 2: multi-city

  var isLoading = false.obs;
  var searchResults = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

// Getter for formatted origins string
  String get formattedOrigins => origins.isNotEmpty ? ',${origins.join(',')}' : '';

// Getter for formatted destinations string
  String get formattedDestinations => destinations.isNotEmpty ? ',${destinations.join(',')}' : '';

  // Method to update origins and destinations
  void updateRoute(int index, {String? origin, String? destination}) {
    if (origin != null) {
      if (index >= origins.length) {
        origins.add(origin);
      } else {
        origins[index] = origin;
      }
    }

    if (destination != null) {
      if (index >= destinations.length) {
        destinations.add(destination);
      } else {
        destinations[index] = destination;
      }
    }
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

      // Format dates based on trip type
      String formattedDates = '';

      if (currentTripType.value == 2) {
        // For multi-city trips
        final flights = flightDateController.flights;

        // Make sure we have cities selected for all flights
        if (origins.length < flights.length || destinations.length < flights.length) {
          errorMessage.value = 'Please select all departure and destination cities';
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

        // Make sure we have at least one origin and destination
        if (origins.isEmpty || destinations.isEmpty) {
          errorMessage.value = 'Please select both departure and destination cities';
          isLoading.value = false;
          return;
        }

        formattedDates = ',${_formatDate(flightDateController.departureDate.value)}';

        if (currentTripType.value == 1) {
          formattedDates += ',${_formatDate(flightDateController.returnDate.value)}';
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
              : (currentTripType.value == 2 ? FlightScenario.multiCity : FlightScenario.oneWay)
      ));

    } catch (e, stackTrace) {
      print('Error in searchFlights: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Error searching flights: $e';

      searchResults.value = null;
      flightController.loadFlights({
        'groupedItineraryResponse': {
          'scheduleDescs': [],
          'itineraryGroups': []
        }
      });
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}