import 'package:dio/dio.dart';
import 'package:get/get.dart';

class SearchHotelController extends GetxController {
  // Define the hotels list with explicit type
  final RxList<Map<String, dynamic>> hotels = <Map<String, dynamic>>[

  ].obs;
  // Function to open location in maps

  // Observable lists with explicit types
  final RxList<Map<String, dynamic>> filteredHotels =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> originalHotels =
      <Map<String, dynamic>>[].obs;
  final RxList<bool> selectedRatings = List<bool>.filled(5, false).obs;

  var dio = Dio();

  filterhotler(){
    originalHotels.value = List<Map<String, dynamic>>.from(hotels);
    filteredHotels.value = List<Map<String, dynamic>>.from(hotels);
  }


  void filterByRating() {
    List<int> selectedStars = [];

    // Collect selected ratings based on the selected checkboxes
    for (int i = 0; i < selectedRatings.length; i++) {
      if (selectedRatings[i]) {
        selectedStars.add(5 - i); // Match stars with index
      }
    }

    // Debugging: Print the selected ratings
    print("Selected ratings: $selectedStars");

    if (selectedStars.isEmpty) {
      // Show all hotels if no filter is selected
      filteredHotels.value = List<Map<String, dynamic>>.from(originalHotels);
    } else {
      // Apply the rating filter
      filteredHotels.value = originalHotels
          .where((hotel) => selectedStars.contains(hotel['rating']))
          .toList();
      hotels.value = filteredHotels;

      // Debugging: Print the filtered list
      print("Filtered hotels: $filteredHotels");
    }
  }

  // Method to filter hotels by price range
  void filterByPriceRange(double minPrice, double maxPrice) {
    try {
      // Create a new list with filtered hotels
      List<Map<String, dynamic>> filtered = originalHotels.where((hotel) {
        // Remove commas and parse the price to a double
        double price =
        double.parse(hotel['price'].toString().replaceAll(',', '').trim());
        return price >= minPrice && price <= maxPrice;
      }).toList();

      // Update the filtered and main lists
      filteredHotels.value = filtered;
      hotels.value = filtered;
    } catch (e) {
      print('Error filtering hotels: $e');
    }
  }

  // Method to sort hotels
  void sortHotels(String sortOption) {
    try {
      List<Map<String, dynamic>> sortedList =
      List<Map<String, dynamic>>.from(hotels);

      switch (sortOption) {
        case 'Price (low to high)':
          sortedList.sort((a, b) {
            double priceA =
            double.parse(a['price'].toString().replaceAll(',', '').trim());
            double priceB =
            double.parse(b['price'].toString().replaceAll(',', '').trim());
            return priceA.compareTo(priceB);
          });
          break;

        case 'Price (high to low)':
          sortedList.sort((a, b) {
            double priceA =
            double.parse(a['price'].toString().replaceAll(',', '').trim());
            double priceB =
            double.parse(b['price'].toString().replaceAll(',', '').trim());
            return priceB.compareTo(priceA);
          });
          break;

        case 'Recommended':
          sortedList = List<Map<String, dynamic>>.from(originalHotels);
          break;
      }

      hotels.value = sortedList;
    } catch (e) {
      print('Error sorting hotels: $e');
    }
  }

  // Reset filters
  void resetFilters() {
    hotels.value = List<Map<String, dynamic>>.from(originalHotels);
  }

  void searchHotelsByName(String query) {
    try {
      if (query.isEmpty) {
        // If query is empty, reset to original hotels
        hotels.value = List<Map<String, dynamic>>.from(originalHotels);
      } else {
        // Filter hotels based on the name matching the query
        hotels.value = originalHotels
            .where((hotel) => hotel['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    } catch (e) {
      print('Error searching hotels by name: $e');
    }
  }

  var roomsdata = [].obs;

  var hotelName = ''.obs;
  var image = ''.obs;
  var hotelCode =''.obs;
  var sessionId =''.obs;
  var destinationCode =''.obs;
  var hotelCity =''.obs;

// Add this property to store selected rooms data
  final RxList<Map<String, dynamic>> selectedRoomsData = <Map<String, dynamic>>[].obs;

  // Add this method to update selected rooms data
  void updateSelectedRoom(int index, Map<String, dynamic> roomData) {
    if (selectedRoomsData.length <= index) {
      selectedRoomsData.add(roomData);
    } else {
      selectedRoomsData[index] = roomData;
    }
  }

}