import 'package:flight_bocking/home_search/search_flights/search_flight_utils/flight_controller.dart';
import 'package:get/get.dart';
import '../../../../services/api_service_flight.dart';
import '../../../search_flights/search_flights.dart';
import 'flight_date_controller.dart';
import 'travelers/traveler_controller.dart';

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

      // Format the dates based on trip type
      String formattedDates = ',${_formatDate(flightDateController.departureDate.value)}';
      if (tripType == 1) {
        formattedDates += ',${_formatDate(flightDateController.returnDate.value)}';
      } else if (tripType == 2) {
        for (var flight in flightDateController.flights) {
          formattedDates += ',${_formatDate(flight['date'])}';
        }
      }

      print('Search parameters:');
      print('Trip type: $tripType');
      print('Dates: $formattedDates');
      print('Origin: LHE');
      print('Destination: JED');
      print('Adults: ${travelersController.adultCount.value}');
      print('Cabin: ${travelersController.travelClass.value}');

      final results = await apiServiceFlight.searchFlights(
        type: tripType,
        origin: ",KHI",
        destination: ",JED",
        depDate: formattedDates,
        adult: travelersController.adultCount.value,
        child: travelersController.childrenCount.value,
        infant: travelersController.infantCount.value,
        stop: 2,
        cabin: travelersController.travelClass.value.toUpperCase(),
      );

      print('API response received:');
      print(results);

      if (results == null) {
        throw Exception('No results returned from API');
      }

      searchResults.value = results;

      // Initialize the flight controller with the results
      print('Initializing flight controller with results...');
      flightController.loadFlights(results);

      // If we get here, the search was successful
      print('Flight search completed successfully');

      // Navigate based on trip type
      if (flightDateController.tripType.value == 'One-way') {
        Get.to(() => FlightBookingPage(scenario: FlightScenario.oneWay));
      } else {
        Get.to(() => FlightBookingPage(scenario: FlightScenario.returnFlight));
      }

    } catch (e, stackTrace) {
      print('Error in searchFlights: $e');
      print('Stack trace: $stackTrace');
      errorMessage.value = 'Error searching flights: $e';

      // Set empty results when there's an error
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