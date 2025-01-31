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

  // Helper method to store token and its expiry
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(Duration(hours: 5));
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
  }

  // Helper method to check if token is valid
  Future<String?> _getValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryTimeStr = prefs.getString(_tokenExpiryKey);

    if (token != null && expiryTimeStr != null) {
      final expiryTime = DateTime.parse(expiryTimeStr);
      if (DateTime.now().isBefore(expiryTime)) {
        return token;
      }
    }
    return null;
  }

  // Generate new token
  Future<String> generateToken() async {
    try {
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

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _storeToken(token);
        return token;
      } else {
        throw Exception('Failed to generate token');
      }
    } catch (e) {
      throw Exception('Error generating token: $e');
    }
  }

  // Get token (either existing valid token or generate new one)
  Future<String> getToken() async {
    final validToken = await _getValidToken();
    if (validToken != null) {
      return validToken;
    }
    return generateToken();
  }

  // Search flights
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

    // Prepare origin, destination and dates arrays
    final originArray = origin.split(',');
    final destinationArray = destination.split(',');
    final depDateArray = depDate.split(',');

    // Build originDestination section based on trip type
    List<Map<String, dynamic>> originDestinations = [];

    if (type == 0) { // One way
      originDestinations.add({
        "RPH": "1",
        "DepartureDateTime": "${depDateArray[1]}T00:00:01",
        "OriginLocation": {
          "LocationCode": originArray[1].toUpperCase()
        },
        "DestinationLocation": {
          "LocationCode": destinationArray[1].toUpperCase()
        }
      });
    } else if (type == 1) { // Round trip
      originDestinations.addAll([
        {
          "RPH": "1",
          "DepartureDateTime": "${depDateArray[1]}T00:00:01",
          "OriginLocation": {
            "LocationCode": originArray[1].toUpperCase()
          },
          "DestinationLocation": {
            "LocationCode": destinationArray[1].toUpperCase()
          }
        },
        {
          "RPH": "2",
          "DepartureDateTime": "${depDateArray[2]}T00:00:01",
          "OriginLocation": {
            "LocationCode": destinationArray[1].toUpperCase()
          },
          "DestinationLocation": {
            "LocationCode": originArray[1].toUpperCase()
          }
        }
      ]);
    } else if (type == 2) { // Multi-city
      for (int i = 1; i < originArray.length; i++) {
        originDestinations.add({
          "RPH": "$i",
          "DepartureDateTime": "${depDateArray[i]}T00:00:01",
          "OriginLocation": {
            "LocationCode": originArray[i].toUpperCase()
          },
          "DestinationLocation": {
            "LocationCode": destinationArray[i].toUpperCase()
          }
        });
      }
    }

    // Build passenger array
    List<Map<String, dynamic>> passengers = [];
    if (adult > 0) {
      passengers.add({"Code": "ADT", "Quantity": adult});
    }
    if (child > 0) {
      passengers.add({"Code": "CNN", "Quantity": child});
    }
    if (infant > 0) {
      passengers.add({"Code": "INF", "Quantity": infant});
    }

    final requestBody = {
      "OTA_AirLowFareSearchRQ": {
        "ResponseType": "OTA",
        "ResponseVersion": "4.3.0",
        "Version": "4.3.0",
        "OriginDestinationInformation": originDestinations,
        "POS": {
          "Source": [
            {
              "PseudoCityCode": "6MD8",
              "RequestorID": {
                "CompanyName": {"Code": "TN"},
                "ID": "1",
                "Type": "1"
              }
            }
          ]
        },
        "TPA_Extensions": {
          "IntelliSellTransaction": {
            "RequestType": {"Name": "50ITINS"}
          }
        },
        "TravelPreferences": {
          "ValidInterlineTicket": true,
          "CabinPref": [
            {
              "Cabin": cabin,
              "PreferLevel": "Preferred"
            }
          ],
          "TPA_Extensions": {
            "DataSources": {
              "ATPCO": "Enable",
              "LCC": "Enable",
              "NDC": "Enable"
            },
            "NumTrips": {"Number": 50},
            "NDCIndicators": {
              "MultipleBrandedFares": {"Value": true},
              "MaxNumberOfUpsells": {"Value": 6}
            }
          },
          "MaxStopsQuantity": 2
        },
        "TravelerInfoSummary": {
          "SeatsRequested": [adult + child + infant],
          "AirTravelerAvail": [
            {
              "PassengerTypeQuantity": passengers
            }
          ]
        }
      }
    };

    try {
      final response = await dio.post(
        '/v3/offers/shop',
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to search flights');
      }
    } catch (e) {
      throw Exception('Error searching flights: $e');
    }
  }
}