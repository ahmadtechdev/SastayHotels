import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../home_search/search_hotels/search_hotle_Controler.dart';

class ApiService extends GetxService {
  final String _apiKey = 'VSXYTrVlCtVXRAOXGS2==';
  final String _apiUrl = 'http://uat-apiv2.giinfotech.ae/api/v2/Hotel/Search';

  // Initialize the existing SearchHotelController
  ApiService() {
    if (!Get.isRegistered<SearchHotelController>()) {
      Get.put(SearchHotelController());
    }
  }

  String _formatDate(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat("yyyy-MM-dd").format(dateTime);
    } catch (e) {
      print('Date formatting error: $e');
      return isoDate;
    }
  }

  Future<void> fetchHotels({
    required String destinationCode,
    required String countryCode,
    required String nationality,
    required String currency,
    required String checkInDate,
    required String checkOutDate,
    required List<Map<String, dynamic>> rooms,
  }) async {
    final searchController = Get.find<SearchHotelController>();

    print('\n=== Starting Hotel Search API Call ===');
    print('Input Parameters:');
    print('DestinationCode: $destinationCode');
    print('CountryCode: $countryCode');
    print('Nationality: $nationality');
    print('Currency: $currency');
    print('Original CheckInDate: $checkInDate');
    print('Original CheckOutDate: $checkOutDate');
    print('Rooms: $rooms');

    // Format dates correctly
    final formattedCheckInDate = _formatDate(checkInDate);
    final formattedCheckOutDate = _formatDate(checkOutDate);

    print('\nFormatted Dates:');
    print('Formatted CheckInDate: $formattedCheckInDate');
    print('Formatted CheckOutDate: $formattedCheckOutDate');

    var headers = {
      'apikey': _apiKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    var requestBody = {
      "SearchParameter": {
        "DestinationCode": destinationCode,
        "CountryCode": countryCode,
        "Nationality": nationality,
        "Currency": currency,
        "CheckInDate": formattedCheckInDate,
        "CheckOutDate": formattedCheckOutDate,
        "Rooms": {
          "Room": rooms
              .map((room) => {
                    "RoomIdentifier": room["RoomIdentifier"],
                    "Adult": room["Adult"],
                  })
              .toList(),
        },
        "TassProInfo": {"CustomerCode": "4805", "RegionID": "123"}
      }
    };

    print('\nRequest Body:');
    print(json.encode(requestBody));

    try {
      print('\nInitiating API request...');
      var request = http.Request('POST', Uri.parse(_apiUrl));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      print('\nSending request...');
      http.StreamedResponse response = await request.send();
      print('\nResponse Status Code: ${response.statusCode}');

      String responseBody = await response.stream.bytesToString();
      print('\nRaw Response Body:');
      print(responseBody);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(responseBody);

        if (responseData['hotels'] != null) {
          print('\nHotels data found in response');
          List<dynamic> apiHotels = responseData['hotels']['hotel'];

          // Transform API hotel data to match your existing format
          List<Map<String, dynamic>> transformedHotels = apiHotels.map((hotel) {
            return {
              'name': hotel['name'] ?? 'Unknown Hotel',
              'price': hotel['minPrice']?.toString() ?? '0',
              'address': hotel['hotelInfo']['add1'] ?? 'Address not available',
              'image': hotel['hotelInfo']['image'] ?? 'assets/img/cardbg/broken-image.png',
              // Default image or from API
              'rating': double.tryParse(hotel['hotelInfo']['starRating']?.toString() ?? '') ?? 3.0,
              'latitude': hotel['hotelInfo']['lat'] ?? 0.0,
              'longitude': hotel['hotelInfo']['lon'] ?? 0.0,
              'hotelCode':hotel['code']??"",
              // Add any additional fields that your existing controller uses
            };
          }).toList();

          print('Transformed ${transformedHotels.length} hotels');

          // Update the existing controller
          searchController.hotels.value = transformedHotels;
          searchController.originalHotels.value = transformedHotels;
          searchController.filteredHotels.value = transformedHotels;

          print('Successfully updated SearchHotelController with new data');
        } else {
          print('\nNo hotels found in the response');
          throw Exception('No hotels data in response');
        }
      } else {
        print('\nAPI request failed');
        print('Status code: ${response.statusCode}');
        print('Reason: ${response.reasonPhrase}');
        throw Exception('Failed to fetch hotels: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('\n=== Error in API Call ===');
      print('Error type: ${e.runtimeType}');
      print('Error details: $e');
      rethrow;
    } finally {
      print('\n=== End of Hotel Search API Call ===\n');
    }
  }
}
