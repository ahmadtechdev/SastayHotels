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

  Future<String?> getValidToken() async {
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
            'Authorization':
                'Basic VmpFNk5UVTFOVG8yVFVRNE9rRkI6Ykhsd2EyaHBNak09',
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
      final token = await getValidToken() ?? await generateToken();
      print('Token received.');

      final originArray = origin.split(',');
      final destinationArray = destination.split(',');
      final depDateArray = depDate.split(',');

      final mappedCabin = _mapCabinClass(cabin);

      List<Map<String, dynamic>> originDestinations = [];
      List<Map<String, dynamic>> passengers = [];

      if (type == 0) {
        // One-way trip
        originDestinations.add({
          "RPH": "1",
          "DepartureDateTime": "${depDateArray[1]}T00:00:01",
          "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
          "DestinationLocation": {
            "LocationCode": destinationArray[1].toUpperCase()
          }
        });
      } else if (type == 1) {
        // Return trip
        originDestinations.addAll([
          {
            "RPH": "1",
            "DepartureDateTime": "${depDateArray[1]}T00:00:01",
            "OriginLocation": {"LocationCode": originArray[1].toUpperCase()},
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
      } else if (type == 2) {
        // Multi-city trip
        // Skip the first empty element in the arrays (due to leading comma)
        for (int i = 1; i < depDateArray.length; i++) {
          if (i < originArray.length && i < destinationArray.length) {
            originDestinations.add({
              "RPH": "$i",
              "DepartureDateTime": "${depDateArray[i]}T00:00:01",
              "OriginLocation": {"LocationCode": originArray[i].toUpperCase()},
              "DestinationLocation": {
                "LocationCode": destinationArray[i].toUpperCase()
              }
            });
          }
        }
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
              {"Cabin": mappedCabin, "PreferLevel": "Preferred"}
            ],
            "VendorPref": [{}],
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
              },
              "TripType": {
                "Value": type == 1 ? "Return" : (type == 2 ? "Other" : "OneWay")
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
      print(jsonString.substring(
          i,
          i + chunkSize > jsonString.length
              ? jsonString.length
              : i + chunkSize));
    }
  }

  Future<Map<String, dynamic>?> checkFlightAvailability({
    required String token,
    required String origin,
    required String destination,
    required String departureDateTime,
    String? returnDateTime,
    required String cabinClass,
    required int adultCount,
    required int childCount,
    required int infantCount,
    required List<Map<String, dynamic>> flights,
  }) async {
    try {
      // Validate input parameters
      if (flights.isEmpty) {
        throw Exception('No flight segments provided');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Build passenger types with proper validation
      final List<Map<String, dynamic>> passengerTypes = [];
      if (adultCount > 0) {
        passengerTypes
            .add({"Code": "ADT", "Quantity": adultCount, "TPA_Extensions": {}});
      }
      if (childCount > 0) {
        passengerTypes
            .add({"Code": "CNN", "Quantity": childCount, "TPA_Extensions": {}});
      }
      if (infantCount > 0) {
        passengerTypes.add(
            {"Code": "INF", "Quantity": infantCount, "TPA_Extensions": {}});
      }

      // Process flight segments with proper type handling
      List<Map<String, dynamic>> processedFlights = flights.map((flight) {
        return {
          "ClassOfService": flight['cabinCode'] ?? 'L',
          "Number": _parseFlightNumber(flight['Number']),
          "DepartureDateTime": flight['DepartureDateTime'],
          "ArrivalDateTime": flight['ArrivalDateTime'],
          "Type": flight['Type'] ?? 'A',
          "OriginLocation": {
            "LocationCode": flight['OriginLocation']['LocationCode']
          },
          "DestinationLocation": {
            "LocationCode": flight['DestinationLocation']['LocationCode']
          },
          "Airline": {
            "Operating": flight['Airline']['Operating'],
            "Marketing": flight['Airline']['Marketing']
          }
        };
      }).toList();

      // Build origin destination information
      final List<Map<String, dynamic>> originDestInfo = [
        {
          "RPH": "1",
          "DepartureDateTime": departureDateTime,
          "OriginLocation": {"LocationCode": origin.toUpperCase()},
          "DestinationLocation": {"LocationCode": destination.toUpperCase()},
          "TPA_Extensions": {
            "Flight": processedFlights
                .where((f) =>
                    f['OriginLocation']['LocationCode'] ==
                        origin.toUpperCase() ||
                    f['DestinationLocation']['LocationCode'] ==
                        destination.toUpperCase())
                .toList(),
            "SegmentType": {"Code": "O"}
          }
        }
      ];

      // Add return flight if exists
      if (returnDateTime != null) {
        originDestInfo.add({
          "RPH": "2",
          "DepartureDateTime": returnDateTime,
          "OriginLocation": {"LocationCode": destination.toUpperCase()},
          "DestinationLocation": {"LocationCode": origin.toUpperCase()},
          "TPA_Extensions": {
            "Flight": processedFlights
                .where((f) =>
                    f['OriginLocation']['LocationCode'] ==
                        destination.toUpperCase() ||
                    f['DestinationLocation']['LocationCode'] ==
                        origin.toUpperCase())
                .toList(),
            "SegmentType": {"Code": "O"}
          }
        });
      }

      final requestData = {
        "OTA_AirLowFareSearchRQ": {
          "Version": "4",
          "TravelPreferences": {
            "LookForAlternatives": false,
            "TPA_Extensions": {
              "VerificationItinCallLogic": {
                "AlwaysCheckAvailability": true,
                "Value": "B"
              }
            }
          },
          "TravelerInfoSummary": {
            "SeatsRequested": [adultCount + childCount + infantCount],
            "AirTravelerAvail": [
              {"PassengerTypeQuantity": passengerTypes}
            ],
            "PriceRequestInformation": {
              "TPA_Extensions": {
                "BrandedFareIndicators": {
                  "MultipleBrandedFares": true,
                  "ReturnBrandAncillaries": true
                }
              }
            }
          },
          "POS": {
            "Source": [
              {
                "PseudoCityCode": "6MD8",
                "RequestorID": {
                  "Type": "1",
                  "ID": "1",
                  "CompanyName": {"Code": "TN"}
                }
              }
            ]
          },
          "OriginDestinationInformation": originDestInfo,
          "TPA_Extensions": {
            "IntelliSellTransaction": {
              "RequestType": {"Name": "50ITINS"}
            }
          }
        }
      };

      final response = await dio.post(
        '/v4/shop/flights/revalidate',
        options: Options(headers: headers),
        data: requestData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to check flight availability: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioError in flight availability check: ${e.message}');
      print('Response data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('Error in flight availability check: $e');
      rethrow;
    }
  }

  // Helper method to handle flight number parsing
  String _parseFlightNumber(dynamic number) {  
    if (number is int) {
      return number.toString();
    } else if (number is String) {
      return number;
    }
    throw FormatException('Invalid flight number format: $number');
  }
}
