import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceFlight extends GetxService {
  late final Dio dio;
  static const String _baseUrl = 'https://api.havail.sabre.com';
  static const String _tokenKey = 'flight_api_token';
  static const String _tokenExpiryKey = 'flight_token_expiry';

  ApiServiceFlight() {
    dio = Dio(BaseOptions(baseUrl: _baseUrl));
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(Duration(hours: 5));
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
    print("Token stored successfully: $token");
  }

  Future<String?> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryTimeStr = prefs.getString(_tokenExpiryKey);

    if (token != null && expiryTimeStr != null) {
      final expiryTime = DateTime.parse(expiryTimeStr);
      if (DateTime.now().isBefore(expiryTime)) {
        print("Using cached token: $token");
        return token;
      }
    }
    print("No valid token found. Generating new one.");
    return null;
  }

  Future<String> generateToken() async {
    try {
      print("Generating new token...");
      final response = await dio.post(
        '/v2/auth/token',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic VmpFNk5UVTFOVG8yVFVRNE9rRkI6Ykhsd2EyaHBNak09',
            'grant_type': 'client_credentials',
          },
        ),
      );

      print("Token response: ${response.data}");
      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _storeToken(token);
        return token;
      } else {
        throw Exception('Failed to generate token');
      }
    } catch (e) {
      print("Error generating token: $e");
      throw Exception('Error generating token: $e');
    }
  }

  Future<String> getToken() async {
    final validToken = await _getValidToken();
    return validToken ?? await generateToken();
  }

  Future<Map<String, dynamic>> searchFlights({
    required int type,
    required String origin,
    required String destination,
    required String depDate,
    required int adult,
    required int child,
    required int infant,
    required int stop,
    required String cabin,
  }) async {
    final token = await getToken();
    print("Using token: $token");

    final originArray = origin.split(',');
    final destinationArray = destination.split(',');
    final depDateArray = depDate.split(',');

    List<Map<String, dynamic>> originDestinations = [];

    if (type == 0) {
      originDestinations.add({
        "RPH": "1",
        "DepartureDateTime": "${depDateArray[1]}T00:00:01",
        "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
        "DestinationLocation": {"LocationCode": destinationArray[1].toUpperCase()}
      });
    } else if (type == 1) {
      originDestinations.addAll([
        {
          "RPH": "1",
          "DepartureDateTime": "${depDateArray[1]}T00:00:01",
          "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
          "DestinationLocation": {"LocationCode": destinationArray[1].toUpperCase()}
        },
        {
          "RPH": "2",
          "DepartureDateTime": "${depDateArray[2]}T00:00:01",
          "OriginLocation": {"LocationCode": destinationArray[1].toUpperCase()},
          "DestinationLocation": {"LocationCode": originArray[1].toUpperCase()}
        }
      ]);
    }

    List<Map<String, dynamic>> passengers = [];
    if (adult > 0) passengers.add({"Code": "ADT", "Quantity": adult});
    if (child > 0) passengers.add({"Code": "CNN", "Quantity": child});
    if (infant > 0) passengers.add({"Code": "INF", "Quantity": infant});

    final requestBody = {
      "OTA_AirLowFareSearchRQ": {
        "ResponseType": "OTA",
        "ResponseVersion": "4.3.0", // Added ResponseVersion
        "Version": "4.3.0",
        "OriginDestinationInformation": originDestinations,
        "POS": {
          "Source": [{
            "PseudoCityCode": "6MD8",
            "RequestorID": {
              "CompanyName": {"Code": "TN"}, // Added CompanyName
              "ID": "1",
              "Type": "1"
            }
          }]
        },
        "TPA_Extensions": {
          "IntelliSellTransaction": {
            "RequestType": {"Name": "50ITINS"}
          }
        },
        "TravelPreferences": {
          "ValidInterlineTicket": true,
          "CabinPref": [{"Cabin": cabin, "PreferLevel": "Preferred"}],
          "VendorPref": [{}], // Added VendorPref
          "TPA_Extensions": { // Added TravelPreferences TPA_Extensions
            "DataSources": {
              "ATPCO": "Enable",
              "LCC": "Enable",
              "NDC": "Enable"
            },
            "NumTrips": {"Number": 50},
            "NDCIndicators": {
              "MultipleBrandedFares": {"Value": true},
              "MaxNumberOfUpsells": {"Value": 6}
            },
            "TripType": {"Value": type == 1 ? "Return" : "OneWay"}
          },
          "MaxStopsQuantity": stop
        },
        "TravelerInfoSummary": {
          "SeatsRequested": [adult + child + infant],
          "AirTravelerAvail": [{"PassengerTypeQuantity": passengers}]
        }
      }
    };

    try {
      print("Request payload: ${jsonEncode(requestBody)}");
      final response = await dio.post(
        '/v3/offers/shop',
        data: jsonEncode(requestBody),
        options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            }
        ),
      );

      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to search flights');
      }
    } catch (e) {
      print("Error searching flights: $e");
      throw Exception('Error searching flights: $e');
    }
  }
}
