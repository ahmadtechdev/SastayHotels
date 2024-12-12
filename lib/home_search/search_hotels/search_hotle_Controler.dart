import 'package:get/get.dart';

class SearchHotelController extends GetxController {
  // Define the hotels list with explicit type
  final RxList<Map<String, dynamic>> hotels = <Map<String, dynamic>>[
    {
      'name': 'Al Shohada Hotel',
      'price': ' 59,946',
      'address': 'Ajyad Street P.O. Box 10056, Makkah 21955',
      'image': 'assets/img/cardbg/2.jpg',
      'rating': 5,
    },
    {
      'name': 'Mecca Hotel',
      'price': ' 45,500',
      'address': 'Makkah City Center',
      'image': 'assets/img/cardbg/3.jpg',
      'rating': 4,
    },
    {
      'name': 'Jeddah Resort',
      'price': ' 35,200',
      'address': 'Red Sea District, Jeddah',
      'image': 'assets/img/cardbg/4.jpg',
      'rating': 1,
    },
    {
      'name': 'Riyadh Grand Hotel',
      'price': ' 80,000',
      'address': 'King Fahd Road, Riyadh 11564',
      'image': 'assets/img/cardbg/5.jpg',
      'rating': 5,
    },
    {
      'name': 'Madinah Plaza',
      'price': ' 55,300',
      'address': 'Al Haram, Madinah 42311',
      'image': 'assets/img/cardbg/6.jpg',
      'rating': 3,
    },
    {
      'name': 'Qatar Beach Resort',
      'price': ' 70,000',
      'address': 'Doha Corniche, Qatar',
      'image': 'assets/img/cardbg/7.jpg',
      'rating': 2,
    },
  ].obs;

  // Observable lists with explicit types
  final RxList<Map<String, dynamic>> filteredHotels =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> originalHotels =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize lists with proper type casting
    originalHotels.value = List<Map<String, dynamic>>.from(hotels);
    filteredHotels.value = List<Map<String, dynamic>>.from(hotels);
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
}
