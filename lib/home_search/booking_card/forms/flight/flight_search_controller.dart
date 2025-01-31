import 'package:get/get.dart';
import '../../../../services/api_service_flight.dart';
import 'flight_date_controller.dart';
import 'travelers/traveler_controller.dart';

class FlightSearchController extends GetxController {
  final apiServiceFlight = Get.put(ApiServiceFlight());
  final travelersController = Get.put(TravelersController());
  final flightDateController = Get.put(FlightDateController());

  var isLoading = false.obs;
  var searchResults = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  Future<void> searchFlights() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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

      // Hard coded cities for testing
      const origin = ",KHI";
      const destination = ",JED";

      final results = await apiServiceFlight.searchFlights(
        type: tripType,
        origin: origin,
        destination: destination,
        depDate: formattedDates,
        adult: travelersController.adultCount.value,
        child: travelersController.childrenCount.value,
        infant: travelersController.infantCount.value,
        stop: 0,
        cabin: travelersController.travelClass.value.toUpperCase(),
      );

      searchResults.value = results;
      print('Flight Search Results:');
      print(results);

    } catch (e) {
      errorMessage.value = 'Error searching flights: $e';
      print('Error searching flights: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}