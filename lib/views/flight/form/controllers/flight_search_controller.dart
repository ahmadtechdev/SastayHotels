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

  var isLoading = false.obs;
  var searchResults = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  Future<void> searchFlights() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('Starting flight search...');

      // Get the trip type (0 for one-way, 1 for return, 2 for multi-city)
      int tripType;
      switch (flightDateController.tripType.value) {
        case 'One-way':
          tripType = 0;
          break;
        case 'Return':
          tripType = 1;
          break;
        case 'Multi City':
          tripType = 2;
          break;
        default:
          tripType = 0;
      }

      // Format origin, destination, and dates based on trip type
      String origins = '';
      String destinations = '';
      String formattedDates = '';

      if (tripType == 2) {
        // For multi-city trips, we need to get the origins, destinations and dates from the flights array
        final flights = flightDateController.flights;

        for (int i = 0; i < flights.length; i++) {
          // Only add the comma if it's not the first item
          if (i > 0) {
            origins += ',';
            destinations += ',';
            formattedDates += ',';
          } else {
            // Add initial comma for the first item to match the format
            origins += ',';
            destinations += ',';
            formattedDates += ',';
          }

          // Get origin and destination from the flights array
          // Fallback to hardcoded values if not set
          String origin = flights[i]['origin'] ?? 'KHI';
          if (i == 1) origin = 'DXB';  // For the second flight, use DXB as origin

          String destination = flights[i]['destination'] ?? (i == 0 ? 'DXB' : 'JED');

          origins += origin;
          destinations += destination;
          formattedDates += _formatDate(flights[i]['date']);
        }

        // If there's only one flight, add a second one
        if (flights.length == 1) {
          origins += ',DXB';
          destinations += ',JED';
          // Use the same date plus one day
          DateTime nextDay = flights[0]['date'].add(Duration(days: 1));
          formattedDates += ',${_formatDate(nextDay)}';
        }
      } else {
        // Handle one-way and return trips
        origins = ",KHI";
        destinations = ",JED";
        formattedDates = ',${_formatDate(flightDateController.departureDate.value)}';

        if (tripType == 1) {
          formattedDates += ',${_formatDate(flightDateController.returnDate.value)}';
        }
      }

      print('Search parameters:');
      print('Trip type: $tripType');
      print('Origins: $origins');
      print('Destinations: $destinations');
      print('Dates: $formattedDates');
      print('Adults: ${travelersController.adultCount.value}');
      print('Cabin: ${travelersController.travelClass.value}');

      final results = await apiServiceFlight.searchFlights(
        type: tripType,
        origin: origins,
        destination: destinations,
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
          scenario: tripType == 1
              ? FlightScenario.returnFlight
              : (tripType == 2 ? FlightScenario.multiCity : FlightScenario.oneWay)
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