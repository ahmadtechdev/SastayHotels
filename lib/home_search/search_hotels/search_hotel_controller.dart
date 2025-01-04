import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchHotelController extends GetxController {
  // Define the hotels list with explicit type
  final RxList<Map<String, dynamic>> hotels = <Map<String, dynamic>>[
    // {
    //   'name': 'Al Shohada Hotel',
    //   'price': ' 59,946',
    //   'address': 'Ajyad Street P.O',
    //   'image': 'assets/img/cardbg/2.jpg',
    //   'rating': 5,
    //   'latitude': 21.4225,
    //   'longitude': 39.8262,
    // },
    // {
    //   'name': 'Mecca Hotel',
    //   'price': ' 45,500',
    //   'address': 'Makkah City Center',
    //   'image': 'assets/img/cardbg/3.jpg',
    //   'rating': 4,
    //   'latitude': 21.4267,
    //   'longitude': 39.8295,
    // },
    // {
    //   'name': 'Jeddah Resort',
    //   'price': ' 35,200',
    //   'address': 'Red Sea District, Jeddah',
    //   'image': 'assets/img/cardbg/4.jpg',
    //   'rating': 1,
    //   'latitude': 21.5433,
    //   'longitude': 39.1728,
    // },
    // {
    //   'name': 'Riyadh Grand Hotel',
    //   'price': ' 80,000',
    //   'address': 'King Fahd Road, Riyadh 11564',
    //   'image': 'assets/img/cardbg/5.jpg',
    //   'rating': 5,
    //   'latitude': 24.7136,
    //   'longitude': 46.6753,
    // },
    // {
    //   'name': 'Madinah Plaza',
    //   'price': ' 55,300',
    //   'address': 'Al Haram, Madinah 42311',
    //   'image': 'assets/img/cardbg/6.jpg',
    //   'rating': 3,
    //   'latitude': 24.4672,
    //   'longitude': 39.6112,
    // },
    // {
    //   'name': 'Qatar Beach Resort',
    //   'price': ' 70,000',
    //   'address': 'Doha Corniche, Qatar',
    //   'image': 'assets/img/cardbg/7.jpg',
    //   'rating': 2,
    //   'latitude': 25.2867,
    //   'longitude': 51.5333,
    // },
    // // Adding more hotels with coordinates
    // {
    //   'name': 'Dubai Marina Hotel',
    //   'price': ' 95,000',
    //   'address': 'Dubai Marina, UAE',
    //   'image': 'assets/img/cardbg/8.jpg',
    //   'rating': 5,
    //   'latitude': 25.0819,
    //   'longitude': 55.1367,
    // },
    // {
    //   'name': 'Abu Dhabi Palace',
    //   'price': ' 120,000',
    //   'address': 'Corniche Road, Abu Dhabi',
    //   'image': 'assets/img/cardbg/9.jpg',
    //   'rating': 5,
    //   'latitude': 24.4539,
    //   'longitude': 54.3773,
    // },
    // Add more hotels as needed
  ].obs;
  // Function to open location in maps

  // Observable lists with explicit types
  final RxList<Map<String, dynamic>> filteredHotels =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> originalHotels =
      <Map<String, dynamic>>[].obs;
  final RxList<bool> selectedRatings = List<bool>.filled(5, false).obs;

  var dio = Dio();

  @override
  void onInit() {
    super.onInit();
    // Initialize lists with proper type casting
   
  }
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


  final RxInt nights = RxInt(1);
  final Rx<DateTimeRange> dateRange = Rx<DateTimeRange>(
    DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 1)),
    ),
  );

  void updateDateRange(DateTimeRange newRange) {
    dateRange.value = newRange;
    nights.value = newRange.duration.inDays;
  }

  void updateNights(int newNights) {
    if (newNights > 0) {
      nights.value = newNights;
      dateRange.value = DateTimeRange(
        start: dateRange.value.start,
        end: dateRange.value.start.add(Duration(days: newNights)),
      );
    }
  }

  void incrementNights() {
    updateNights(nights.value + 1);
  }

  void decrementNights() {
    if (nights.value > 1) {
      updateNights(nights.value - 1);
    }
  }
}
