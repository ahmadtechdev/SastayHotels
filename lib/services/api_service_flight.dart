import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/filter_modal.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/flight/search_flights/booking_flight/booking_flight_controller.dart';

class ApiServiceFlight extends GetxService {
  late final Dio dio;
  static const String _baseUrl = 'https://api.havail.sabre.com';
  static const String _tokenKey = 'flight_api_token';
  static const String _tokenExpiryKey = 'flight_token_expiry';

  // Add a property to store the airline map
  final Rx<Map<String, AirlineInfo>> airlineMap = Rx<Map<String, AirlineInfo>>({});
  // Add a method to get the airline map
  Map<String, AirlineInfo> getAirlineMap() {
    return airlineMap.value;
  }
  // Initialize airline data when service starts
  @override
  void onInit() {
    super.onInit();
    // Fetch airline data when service initializes
    fetchAirlineData().then((data) {
      airlineMap.value = data;
    });
  }


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

      final token = await getValidToken() ?? await generateToken();


      final originArray = origin.split(',');
      final destinationArray = destination.split(',');
      final depDateArray = depDate.split(',');

      final mappedCabin = _mapCabinClass(cabin);

      List<Map<String, dynamic>> passengers = [];
      List<Map<String, dynamic>> originDestinations = [];

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
            "SeatsRequested": [adult + child],
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
      // print('Request Body:');
      // _printJsonPretty(requestBody);

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

      // print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // print('Response Data:');
        // _printJsonPretty(response.data['statistics']);
        return response.data;
      } else {
        throw Exception('Failed to search flights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchFlights: $e');
      throw Exception('Error searching flights: $e');
    }
  }

  // Add to ApiServiceFlight class in api_service_flight.dart

  Future<Map<String, dynamic>> checkFlightAvailability({
    required int type,
    required List<Map<String, dynamic>> flightSegments,
    required Map<String, dynamic> requestBody,
    required int adult,
    required int child,
    required int infant,
  }) async {
    try {
      final token = await getValidToken() ?? await generateToken();

      print('Request Body:');
      _printJsonPretty(requestBody);

      final response = await dio.post(
        '/v4/shop/flights/revalidate',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ),
        data: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body:');
      _printJsonPretty(response.data);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to check flight availability: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking flight availability: $e');
      throw Exception('Error checking flight availability: $e');
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

  Future<Map<String, AirlineInfo>> fetchAirlineData() async {
    Map<String, AirlineInfo> tempAirlineMap = {};

    try {
      var response = await dio.request(
        'https://agent1.pk/api.php?type=airlines',
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        var data = response.data['data'];
        for (var item in data) {
          // Clean and format the logo URL
          String logoUrl = item['logo'];

          // Remove any escaped characters like \t, \n, etc.
          logoUrl = logoUrl.replaceAll(RegExp(r'^\t+'), '');
          // print(logoUrl);

          // // Ensure URL starts with https://
          // if (!logoUrl.startsWith('http://') && !logoUrl.startsWith('https://')) {
          //   logoUrl = 'https://' + logoUrl;
          // }

          tempAirlineMap[item['code']] = AirlineInfo(
            item['name'],
            logoUrl,
          );
        }
        // Update the stored airlineMap
        airlineMap.value = tempAirlineMap;
        print('Airline data fetched successfully. Total airlines: ${tempAirlineMap.length}');

        // Log a few URLs for debugging
        if (tempAirlineMap.isNotEmpty) {
          print('Sample logo URLs:');
          tempAirlineMap.entries.take(3).forEach((entry) {
            print('${entry.key}: ${entry.value.logoPath}');
          });
        }
      } else {
        print('Failed to fetch airline data: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error fetching airline data: $e');
    }

    return tempAirlineMap;
  }


  // Add this function to create the PNR request body
  Future<void> createPNRRequest({
    required Flight flight,
    required List<TravelerInfo> adults,
    required List<TravelerInfo> children,
    required List<TravelerInfo> infants,
    required String bookerEmail,
    required String bookerPhone,
  }) async {
    try {

      // Extract necessary information from the flight and travelers
      final List<Map<String, dynamic>> passengers = [];
      final List<Map<String, dynamic>> flightSegments = [];

      // Add adults
      for (var i = 0; i < adults.length; i++) {
        final adult = adults[i];
        passengers.add({
          "NameNumber": "${i + 1}.1",
          "NameReference": "", // Empty string for adults
          "PassengerType": "ADT",
          "GivenName": "${adult.firstNameController.text} ${adult.titleController.text}", // Concatenate title with first name
          "Surname": adult.lastNameController.text,
          "DateOfBirth": adult.dateOfBirthController.text, // Add date of birth
          "PassportNumber": adult.passportController.text, // Add passport number
          "PassportExpiry": adult.passportExpiryController.text, // Add passport expiry
        });
      }

      // Add children
      for (var i = 0; i < children.length; i++) {
        final child = children[i];
        passengers.add({
          "NameNumber": "${adults.length + i + 1}.1",
          "NameReference": "C04", // Format as C04, C05, etc.
          "PassengerType": "CNN",
          "GivenName": "${child.firstNameController.text} ${child.titleController.text}", // Concatenate title with first name
          "Surname": child.lastNameController.text,
          "DateOfBirth": child.dateOfBirthController.text, // Add date of birth
          "PassportNumber": child.passportController.text, // Add passport number
          "PassportExpiry": child.passportExpiryController.text, // Add passport expiry
        });
      }

      // Add infants
      for (var i = 0; i < infants.length; i++) {
        final infant = infants[i];
        passengers.add({
          "NameNumber": "${i + 1}.1", // Infants reference their respective adults
          "NameReference": "I12", // Format as I12, I13, etc.
          "PassengerType": "INF",
          "Infant": true,
          "GivenName": "${infant.firstNameController.text} ${infant.titleController.text}", // Concatenate title with first name
          "Surname": infant.lastNameController.text,
          "DateOfBirth": infant.dateOfBirthController.text, // Add date of birth
          "PassportNumber": infant.passportController.text, // Add passport number
          "PassportExpiry": infant.passportExpiryController.text, // Add passport expiry
        });
      }

      // Add flight segments
      var i =0;
      for (var leg in flight.legSchedules) {
        for (var schedule in leg['schedules']) {
          flightSegments.add({
            "DepartureDateTime": schedule['departure']['dateTime'],
            "FlightNumber": schedule['carrier']['marketingFlightNumber'].toString(),
            "NumberInParty": passengers.length.toString(),
            "ResBookDesigCode": flight.segmentInfo[i].bookingCode,
            "Status": "NN",
            "DestinationLocation": {
              "LocationCode": schedule['arrival']['airport'],
            },
            "MarketingAirline": {
              "Code": schedule['carrier']['marketing'],
              "FlightNumber": schedule['carrier']['marketingFlightNumber'].toString(),
            },
            "OriginLocation": {
              "LocationCode": schedule['departure']['airport'],
            },
          });


        }
      }

      // Extract FareBasis codes from flight data
      final List<Map<String, dynamic>> fareBasisCodes = [];
      for (var leg in flight.legSchedules) {
        if (leg['fareBasisCode'] != null) {
          fareBasisCodes.add({
            "FareBasis": {
              "Code": leg['fareBasisCode'],
            },
            "RPH": "${fareBasisCodes.length + 1}",
          });
        }
      }

      // Get the first adult's phone and email
      final firstAdultPhone = adults.isNotEmpty ? adults[0].phoneController.text : bookerPhone;
      final firstAdultEmail = adults.isNotEmpty ? adults[0].emailController.text : bookerEmail;

      List<Map<String, String>> passengerType = [];

      if (adults.isNotEmpty) {
        passengerType.add({
          "Code": "ADT",
          "Quantity": adults.length.toString(),
        });
      }

      if (children.isNotEmpty) {
        passengerType.add({
          "Code": "CNN",
          "Quantity": children.length.toString(),
        });
      }

      if (infants.isNotEmpty) {
        passengerType.add({
          "Code": "INF",
          "Quantity": infants.length.toString(),
        });
      }

      // Create the request body
      final requestBody = {
        "CreatePassengerNameRecordRQ": {
          "haltOnAirPriceError": true,
          "haltOnInvalidMCT": true,
          "targetCity": "6MD8", // Assuming default target city
          "version": "2.5.0",
          "TravelItineraryAddInfo": {
            "AgencyInfo": {
              "Ticketing": {
                "TicketType": "7T-A",
              },
            },
            "CustomerInfo": {
              "ContactNumbers": {
                "ContactNumber": passengers
                    .where((passenger) => passenger["PassengerType"] != "INF") // Exclude infants
                    .map((passenger) => {
                  "NameNumber": passenger["NameNumber"],
                  "Phone": firstAdultPhone, // Use first adult's phone for all travelers
                  "PhoneUseType": "M"
                })
                    .toList(),
              },
              "Email": passengers
                  .where((passenger) => passenger["PassengerType"] != "INF") // Exclude infants
                  .map((passenger) => {
                "Address": firstAdultEmail, // Replace @ with //
                "NameNumber": passenger["NameNumber"]
              })
                  .toList(),
              // "PersonName": passengers.map((passenger) => {
              //   "NameNumber": "1.1",
              //   "NameReference": passenger["NameReference"],
              //   "PassengerType": passenger["PassengerType"],
              //   "GivenName": passenger["GivenName"],
              //   "Surname": passenger["Surname"],
              //   if (passenger["PassengerType"] == "INF") "Infant": true, // Add Infant field only for infants
              // }).toList(),
              "PersonName": passengers.asMap().entries.map((entry) {
                int index = entry.key + 1; // Start from 1 instead of 0
                var passenger = entry.value;

                return {
                  "NameNumber": "$index.1", // Incrementing NameNumber
                  "NameReference": passenger["NameReference"],
                  "PassengerType": passenger["PassengerType"],
                  if (passenger["PassengerType"] == "INF") "Infant": true, // Add Infant field only for infants
                  "GivenName": passenger["GivenName"],
                  "Surname": passenger["Surname"],
                };
              }).toList(),

            },
          },
          "AirBook": {
            "OriginDestinationInformation": {
              "FlightSegment": flightSegments,
            },
            "RetryRebook": {
              "Option": true,
            },
            "HaltOnStatus": [
              {"Code": "HL"},
              {"Code": "HN"},
              {"Code": "HX"},
              {"Code": "LL"},
              {"Code": "NN"},
              {"Code": "NO"},
              {"Code": "PN"},
              {"Code": "UC"},
              {"Code": "UN"},
              {"Code": "US"},
              {"Code": "UU"},
            ],
            "RedisplayReservation": {
              "NumAttempts": 10,
              "WaitInterval": 500,
            },
          },
          "AirPrice": [
            {
              "PriceRequestInformation": {
                "Retain": true,
                "OptionalQualifiers": {
                  "PricingQualifiers": {
                    "CommandPricing": fareBasisCodes,
                    "ItineraryOptions": {
                      "SegmentSelect": fareBasisCodes.map((code) => {
                        "Number": code["RPH"],
                        "RPH": code["RPH"],
                      }).toList(),
                    },
                    "PassengerType": passengerType,
                    // "PassengerType": [
                    //   {
                    //     "Code": "ADT",
                    //     "Quantity": adults.length.toString(),
                    //   },
                    //   {
                    //     "Code": "CNN",
                    //     "Quantity": children.length.toString(),
                    //   },
                    //   {
                    //     "Code": "INF",
                    //     "Quantity": infants.length.toString(),
                    //   },
                    // ],
                  },
                },
              },
            },
          ],
          "SpecialReqDetails": {
            "SpecialService": {
              "SpecialServiceInfo": {
                "AdvancePassenger": passengers.map((passenger) {
                  return {
                    "Document": {
                      "IssueCountry": "PK",
                      "NationalityCountry": "PK",
                      "ExpirationDate": passenger["PassportExpiry"], // Use traveler's passport expiry date
                      "Number": passenger["PassportNumber"], // Use traveler's passport number
                      "Type": "P",
                    },
                    "PersonName": {
                      "GivenName": passenger["GivenName"],
                      "MiddleName": "",
                      "Surname": passenger["Surname"],
                      "DateOfBirth": passenger["DateOfBirth"], // Use traveler's date of birth
                      "DocumentHolder": true,
                      "Gender": passenger["PassengerType"] == "INF" ? "M" : "F", // Default to M for infants
                      "LapChild": passenger["PassengerType"] == "INF",
                      "NameNumber": passenger["NameNumber"],
                    },
                  };
                }).toList(),
                "Service": [
                  // Add CTCM and CTCE for all travelers (adults and children)
                  ...passengers
                      .where((passenger) => passenger["PassengerType"] != "INF") // Exclude infants
                      .map((passenger) => [
                    {
                      "SSR_Code": "CTCM",
                      "PersonName": {
                        "NameNumber": passenger["NameNumber"],
                      },
                      "Text": firstAdultPhone,
                    },
                    {
                      "SSR_Code": "CTCE",
                      "PersonName": {
                        "NameNumber": passenger["NameNumber"],
                      },
                      "Text": firstAdultEmail.replaceAll('@', '//'),
                    },
                  ])
                      .expand((x) => x)
                      .toList(),
                  // Add INFT for infants
                  ...passengers
                      .where((passenger) => passenger["PassengerType"] == "INF") // Only for infants
                      .map((passenger) => {
                    "SSR_Code": "INFT",
                    "PersonName": {
                      "NameNumber": passenger["NameNumber"],
                    },
                    "Text":
                    "${passenger["Surname"]}/${passenger["GivenName"].split(' ')[0]}${passenger["GivenName"].split(' ')[1]}/${passenger["DateOfBirth"]}"
                  })
                      .toList(),
                ],
              },
            },
          },
          "PostProcessing": {
            "ARUNK": {
              "keepSegments": true,
              "priorPricing": true,
            },
            "EndTransaction": {
              "Email": {
                "Ind": true,
              },
              "Source": {
                "ReceivedFrom": "AryanB2B",
              },
            },
            "PostBookingHKValidation": {
              "waitInterval": 200,
              "numAttempts": 4,
            },
            "WaitForAirlineRecLoc": {
              "waitInterval": 200,
              "numAttempts": 4,
            },
            "RedisplayReservation": {
              "waitInterval": 1000,
            },
          },
        },
      };

      // Print the request body
      print('PNR Request Body:');
      _printJsonPretty(requestBody);

      // Make the API call
      final token = await getValidToken() ?? await generateToken();
      final response = await dio.post(
        '/v2.5.0/passenger/records?mode=create',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Conversation-ID': '2021.01.DevStudio',
          },
        ),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        print("PNR Response");
        _printJsonPretty(response.data);
print("Next Request Data");
        // Extract necessary data from the PNR response
        final pnrData = response.data['CreatePassengerNameRecordRS'];
        if (pnrData['ApplicationResults']['status'] == 'Complete') {
          final itineraryRefId = pnrData['ItineraryRef']['ID'];
          print('ItineraryRef ID: $itineraryRefId');

          // Extract TotalAmount and CurrencyCode
          final totalAmount = pnrData['AirPrice'][0]['PriceQuote']['PricedItinerary']['TotalAmount'];
          final currencyCode = pnrData['AirPrice'][0]['PriceQuote']['PricedItinerary']['CurrencyCode'];
          print('Total Amount: $totalAmount $currencyCode');

          // Extract passenger-specific amounts
          final airItineraryPricingInfo = pnrData['AirPrice'][0]['PriceQuote']['PricedItinerary']['AirItineraryPricingInfo'];
          for (var aipia in airItineraryPricingInfo) {
            final code = aipia['PassengerTypeQuantity']['Code'];
            final quantity = aipia['PassengerTypeQuantity']['Quantity'];
            final amount = aipia['ItinTotalFare']['TotalFare']['Amount'];
            print('Passenger Type: $code, Quantity: $quantity, Amount: $amount $currencyCode');
          }

          // Call getBooking API
          final bookingDetails = await getBooking(itineraryRefId);
          print('Booking Details: $bookingDetails');
        } else {
          print('PNR creation status is not complete.');
        }
      } else {
        _printJsonPretty(response.data);
      }
    } catch (e) {
      print('Error in createPNRRequest: $e');
      throw Exception('Error creating PNR: $e');
    }
  }

  void handlePnrResponse(Map<String, dynamic> pnrResponse) async {
    final pnrData = pnrResponse['CreatePassengerNameRecordRS'];
    if (pnrData['ApplicationResults']['status'] == 'Complete') {
      final itineraryRefId = pnrData['ItineraryRef']['ID'];
      print('ItineraryRef ID: $itineraryRefId');

      try {
        final bookingDetails = await ApiServiceFlight().getBooking(itineraryRefId);
        print('Booking Details: $bookingDetails');
      } catch (e) {
        print('Error fetching booking details: $e');
      }
    } else {
      print('PNR creation status is not complete.');
    }
  }

  Future<Map<String, dynamic>> getBooking(String pnrId) async {
    try {
      // Get the valid token or generate a new one if necessary
      final token = await getValidToken() ?? await generateToken();

      // Prepare the request body
      final requestBody = {
        "confirmationId": pnrId,
      };

      // Print the request body for debugging
      print('Get Booking Request Body:');
      _printJsonPretty(requestBody);

      // Make the API call
      final response = await dio.post(
        '/v1/trip/orders/getBooking',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        data: requestBody,
      );

      // Print the response for debugging
      print('Get Booking Response:');
      _printJsonPretty(response.data);

      if (response.statusCode == 200) {
        // Return the response data if the request is successful
        return response.data;
      } else {
        // Handle errors
        throw Exception('Failed to get booking details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getBooking: $e');
      throw Exception('Error getting booking details: $e');
    }
  }
}


