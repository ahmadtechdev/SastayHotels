import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../views/hotel/search_hotels/search_hotel_controller.dart';

class ApiServiceHotel extends GetxService {
  final SearchHotelController controller = Get.put(SearchHotelController());

  late final Dio dio;
  static const String _apiKey = 'VSXYTrVlCtVXRAOXGS2==';
  static const String _baseUrl = 'http://uat-apiv2.giinfotech.ae/api/v2';

  ApiServiceHotel() {
    dio = Dio(BaseOptions(baseUrl: _baseUrl));
    if (!Get.isRegistered<SearchHotelController>()) {
      Get.put(SearchHotelController());
    }
  }

  /// Helper: Sets default headers for API requests.
  Options _defaultHeaders() {
    return Options(
      headers: {
        'apikey': _apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
  }


  Future<Map<String, dynamic>?> getCancellationPolicy({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      }
    };

    print(
        'Fetching Cancellation Policy with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/CancellationPolicy',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Cancellation Policy Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Cancellation Policy Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching cancellation policy: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPriceBreakup({
    required String sessionId,
    required String hotelCode,
    required int groupCode,
    required String currency,
    required List<String> rateKeys,
  }) async {
    final requestBody = {
      "SessionId": sessionId,
      "SearchParameter": {
        "HotelCode": hotelCode,
        "GroupCode": groupCode,
        "Currency": currency,
        "RateKeys": {"RateKey": rateKeys},
      }
    };

    print('Fetching Price Breakup with Request: ${json.encode(requestBody)}');
    try {
      final response = await dio.post(
        '/hotel/PriceBreakup',
        data: requestBody,
        options: _defaultHeaders(),
      );

      if (response.statusCode == 200) {
        print('Price Breakup Response: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Price Breakup Failed: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching price breakup: $e');
    }
    return null;
  }

  Future<bool> bookHotel(Map<String, dynamic> requestBody) async {
    const String bookingEndpoint =
        'https://sastayhotels.pk/mobile_thankyou.php';

    try {
      // Log the request for debugging
      print('\n=== SENDING BOOKING REQUEST1 ===');
      print('Endpoint: $bookingEndpoint');
      print('Request Body: ${json.encode(requestBody)}');

      final response = await dio.post(
        bookingEndpoint,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      // Log the response
      print('\n=== BOOKING RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        // Check if the response indicates success
        // You might need to adjust this based on the actual response structure
        if (response.data != null) {
          if (response.data is Map) {
            if (response.data['status'] == 'success' ||
                response.data['success'] == true ||
                response.data['code'] == 200) {
              return true;
            }
          } else if (response.data
              .toString()
              .toLowerCase()
              .contains('success')) {
            return true;
          }
        }
        return true; // Return true if we get 200 but can't determine more specific success
      } else {
        print('Booking failed with status: ${response.statusCode}');
        print('Error message: ${response.statusMessage}');
        return false;
      }
    } on DioException catch (e) {
      print('\n=== BOOKING ERROR ===');
      print('DioError Type: ${e.type}');
      print('Error Message: ${e.message}');
      if (e.response != null) {
        print('Error Response: ${e.response?.data}');
        print('Error Status Code: ${e.response?.statusCode}');
      }
      return false;
    } catch (e) {
      print('\n=== UNEXPECTED ERROR ===');
      print('Error: $e');
      return false;
    }
  }

  final String apiKey = 'd2608a45ff6c31a8feda78765ae53600';
  final String secretKey = '93a80d2ffb';

  String getSignature() {
    // Get current timestamp in seconds
    int utcDate = (DateTime.now().millisecondsSinceEpoch / 1000).round();

    // Assemble the string similar to PHP
    String assemble = '$apiKey$secretKey$utcDate';

    // Generate SHA-256 hash
    var bytes = utf8.encode(assemble);
    var digest = sha256.convert(bytes);
    print(digest);

    return digest.toString();
  }

  Future<void> fetchHotel({
    required String checkInDate,
    required String checkOutDate,
    required List<Map<String, dynamic>> rooms,
  }) async {
    String signature = getSignature();

    var headers = {
      'Api-key': apiKey,
      'X-Signature': signature,
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'Content-Type': 'application/json'
    };
    print(signature);

    var data = json.encode({
      "stay": {"checkIn": checkInDate, "checkOut": checkOutDate},
      "occupancies": rooms
          .map((room) => {
        "rooms": 1,
        "adults": room['Adult'],
        "children": room['Children'],
        if (room['Children'] > 0) "childAges": room['ChildrenAges']
      })
          .toList(),
      "hotels": {
        "hotel": [24196,24197,24199,24202,24203,24204,24216,24217,24218,24219,24220,24221,24222,24225,24226,24229,24230,24340,24341,24399,24400,24401,24403,24406,24407,24408,24409,24412,24413,24421,24422,24423    ]
      }
    });

    try {
      var response = await dio.request(
        'https://api.hotelbeds.com/hotel-api/1.0/hotels',
        options: Options(method: 'POST', headers: headers),
        data: data,
      );

      if (response.statusCode == 200) {
        print(response.data);
        // Store the original response
        controller.originalResponse.value = response.data;

        final hotels = response.data['hotels']['hotels'] as List;
        controller.sessionId.value = response.data['auditData']['token'];

        // Transform hotel data for the UI
        controller.hotels.value = hotels.map((hotel) {
          final minRate = double.parse(hotel['minRate']);
          return {
            'hotelCode': hotel['code'],
            'name': hotel['name'],
            'rating': int.parse(hotel['categoryCode'][0]),
            'address': '${hotel['zoneName']}, ${hotel['destinationName']}',
            'price': minRate.toStringAsFixed(2),
            'image': 'assets/img/cardbg/4.jpg',
            'latitude': hotel['latitude'],
            'longitude': hotel['longitude'],
            'hotelCity': hotel['destinationName']
          };
        }).toList();

        // Store original hotels data
        controller.originalHotels.value = List.from(controller.hotels);
      }
    } catch (e) {
      print("Error fetching hotels: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> checkRate(
      {required List<String> rateKeys}) async {
    String signature = getSignature();

    final headers = {
      'Api-key': apiKey,
      'X-Signature': signature,
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip',
      'Content-Type': 'application/json'
    };

    // Format the request body properly
    var rooms = rateKeys.map((rateKey) => {"rateKey": rateKey}).toList();
    var requestBody = {"rooms": rooms};
    var data = json.encode(requestBody);

    // Pretty print the request data
    print('\n=== Request Data ===');
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    print(encoder.convert(requestBody));

    try {
      final response = await dio.post(
          'https://api.hotelbeds.com/hotel-api/1.0/checkrates',
          options: Options(headers: headers),
          data: data);

      if (response.statusCode == 200) {
        // Split the response logging into smaller chunks
        print('\n=== Response Data ===');

        // Convert response data to pretty JSON string
        String prettyJson = encoder.convert(response.data);

        // Split the pretty JSON into manageable chunks (e.g., 1000 characters)
        const int chunkSize = 1000;
        List<String> chunks = [];

        for (var i = 0; i < prettyJson.length; i += chunkSize) {
          var end = (i + chunkSize < prettyJson.length)
              ? i + chunkSize
              : prettyJson.length;
          chunks.add(prettyJson.substring(i, end));
        }

        // Print each chunk with a separator
        for (var i = 0; i < chunks.length; i++) {
          print('\n--- Chunk ${i + 1}/${chunks.length} ---');
          print(chunks[i]);
        }

        return response.data as Map<String, dynamic>;
      } else {
        print('\n=== Error Response ===');
        print('Status Code: ${response.statusCode}');
        print('Status Message: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('\n=== Exception Caught ===');
      print('Error checking rates: $e');

      // If the error has response data, try to print it
      if (e is DioException && e.response?.data != null) {
        print('\n=== Error Response Data ===');
        try {
          print(encoder.convert(e.response?.data));
        } catch (jsonError) {
          print(e.response?.data.toString());
        }
      }

      return null;
    }
  }
}