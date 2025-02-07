import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceFlight extends GetxService {
  late final Dio dio;
  static const String _baseUrl = 'https://api.havail.sabre.com';
  static const String _tokenKey = 'flight_api_token';
  static const String _tokenExpiryKey = 'flight_token_expiry';

  // Cabin class mapping
  static const Map<String, String> _cabinClassMapping = {
    'ECONOMY': 'Economy',
    'PREMIUM ECONOMY': 'PremiumEconomy',
    'BUSINESS': 'Business',
    'FIRST': 'First',
  };

  String _mapCabinClass(String cabin) {
    return _cabinClassMapping[cabin.toUpperCase()] ?? 'Economy';
  }

  ApiServiceFlight() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      validateStatus: (status) => true,
    ));
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(minutes: 55));
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
  }

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

  // Add to ApiServiceFlight class
  Future<String> generateToken() async {
    try {
      final response = await dio.post(
        '/v2/auth/token',
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Basic VmpFNk5UVTFOVG8yVFVRNE9rRkI6Ykhsd2EyaHBNak09',
            'grant_type': 'client_credentials'
          },
        ),
        // data: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
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
    try {
      print('Fetching token...');
      final token = await _getValidToken() ?? await generateToken();
      print('Token received.');

      final originArray = origin.split(',');
      final destinationArray = destination.split(',');
      final depDateArray = depDate.split(',');

      final mappedCabin = _mapCabinClass(cabin);

      List<Map<String, dynamic>> originDestinations = [];
      List<Map<String, dynamic>> passengers = [];

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

      if (adult > 0) passengers.add({"Code": "ADT", "Quantity": adult});
      if (child > 0) passengers.add({"Code": "CHD", "Quantity": child});
      if (infant > 0) passengers.add({"Code": "INF", "Quantity": infant});

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
                "Cabin": mappedCabin,
                "PreferLevel": "Preferred"
              }
            ],
            "VendorPref": [{}],
            "TPA_Extensions": {
              "DataSources": {
                "ATPCO": "Enable",
                "LCC": "Enable",
                "NDC": "Enable"
              },
              "NumTrips": {
                "Number": 50
              },
              "NDCIndicators": {
                "MultipleBrandedFares": {
                  "Value": true
                },
                "MaxNumberOfUpsells": {
                  "Value": 6
                }
              },
              "TripType": {
                "Value": type == 1 ? "Return" : "OneWay"
              }
            },
            "MaxStopsQuantity": stop
          },
          "TravelerInfoSummary": {
            "SeatsRequested": [adult + child + infant],
            "AirTravelerAvail": [
              {"PassengerTypeQuantity": passengers}
            ],
            "PriceRequestInformation": {
              "TPA_Extensions": {
                "BrandedFareIndicators": {
                  "MultipleBrandedFares": true,
                  "ReturnBrandAncillaries": true,
                  "UpsellLimit": 4,
                  "ParityMode": "Leg",
                  "ParityModeForLowest": "Leg",
                  "ItinParityFallbackMode": "LegParity",
                  "ItinParityBrandlessLeg": true
                }
              }
            }
          }
        }
      };

      // Print request body (formatted)
      print('Request Body:');
      _printJsonPretty(requestBody);

      final response = await dio.post(
        '/v3/offers/shop',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ),
        data: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response Data:');
        _printJsonPretty(response.data['statistics']);
        return response.data;
      } else {
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchFlights: $e');
      throw Exception('Error searching flights: $e');
    }
  }

  /// Helper function to print large JSON data in readable format
  void _printJsonPretty(dynamic jsonData) {
    const int chunkSize = 1000;
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    for (int i = 0; i < jsonString.length; i += chunkSize) {
      print(jsonString.substring(i, i + chunkSize > jsonString.length ? jsonString.length : i + chunkSize));
    }
  }
}