import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/widgets/flight_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/api_service_flight.dart';
import '../../../../widgets/colors.dart';

import '../../form/controllers/flight_date_controller.dart';
import '../../form/travelers/traveler_controller.dart';
import '../review_flight/review_flight.dart';
import '../search_flight_utils/filter_modal.dart';
import '../search_flight_utils/flight_controller.dart';
import '../search_flights.dart';
import 'package_modal.dart';

class PackageSelectionDialog extends StatelessWidget {
  final Flight flight;
  final bool isAnyFlightRemaining;

  PackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isAnyFlightRemaining,
  });

  final PageController _pageController = PageController(viewportFraction: 0.9);
  final flightController = Get.find<FlightController>();
  final flightDateController = Get.find<FlightDateController>();
  final travelersController = Get.find<TravelersController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background2,
      appBar: AppBar(
        backgroundColor: TColors.background,
        surfaceTintColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isAnyFlightRemaining
              ? 'Select Return Flight Package'
              : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFlightInfo(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _buildPackagesList(),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo() {
    return FlightCard(
      flight: flight,
      showReturnFlight: false,
    );
  }

  Widget _buildPackagesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: flight.packages.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOutQuint.transform(value),
                    child: _buildPackageCard(flight.packages[index]),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 50,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  flight.packages.length,
                  (index) => AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: value.abs() < 0.5 ? 24 : 8,
                        decoration: BoxDecoration(
                          color: value.abs() < 0.5
                              ? TColors.primary
                              : TColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(FlightPackageInfo package) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TColors.primary,
                  TColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.cabinName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TColors.background,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.totalPrice.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TColors.background,
                      ),
                    ),
                    Text(
                      package.currency,
                      style: TextStyle(
                        fontSize: 14,
                        color: TColors.background.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPackageDetail(
                      Icons.airline_seat_recline_normal,
                      'Cabin',
                      package.cabinName,
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.luggage,
                      'Baggage',
                      '${package.baggageAllowance.pieces} pieces',
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.restaurant,
                      'Meal',
                      package.mealCode == 'M' ? 'Meal Included' : 'No Meal',
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.event_seat,
                      'Seats Available',
                      package.seatsAvailable.toString(),
                    ),
                    _buildPackageDetail(
                      Icons.currency_exchange,
                      'Refundable',
                      package.isNonRefundable ? 'Non-Refundable' : 'Refundable',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                onSelectPackage();

                if (flightController.currentScenario.value ==
                        FlightScenario.oneWay ||
                    !isAnyFlightRemaining) {
                  // Pass the selected flight to ReviewTripPage
                  Get.to(() => ReviewTripPage(
                        isMulti: false,
                        flight: flight, // Pass the selected flight here
                      ));
                } else {
                  flightController.isSelectingFirstFlight.value = false;
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Text(
                isAnyFlightRemaining
                    ? 'Select Return Package'
                    : 'Select Package',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.background,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColors.primary, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSelectPackage() async {
    try {
      final apiService = ApiServiceFlight();
      final flightAvailabilityService = FlightAvailabilityService();
      final token =
          await apiService.getValidToken() ?? await apiService.generateToken();

      // Extract flight segments from the selected flight
      final List<Map<String, dynamic>> flightSegments = [];

      // Process all flight segments
      for (var legSchedule in flight.legSchedules) {
        final schedules = legSchedule['schedules'] as List;
        for (var schedule in schedules) {
          final carrier = schedule['carrier'];
          flightSegments.add({
            "ClassOfService": flight.cabinClass,
            "Number": carrier['marketingFlightNumber'], // Leave as string
            "DepartureDateTime": flight.departureTime,
            // "DepartureDateTime": "2025-02-20T22:40:00",
            "ArrivalDateTime": flight.arrivalTime,
            // "ArrivalDateTime": "2025-02-22T10:30:00",
            "Type": "A",
            "OriginLocation": {
              "LocationCode": schedule['departure']['airport']
            },
            "DestinationLocation": {
              "LocationCode": schedule['arrival']['airport']
            },
            "Airline": {
              "Operating": carrier['operating'] ?? carrier['marketing'],
              "Marketing": carrier['marketing']
            }
          });
        }
      }

      final origin = flight.from.split('(')[1].split(')')[0].trim();
      final destination = flight.to.split('(')[1].split(')')[0].trim();

      print("flight segments");
      print(flightSegments);

      final availabilityResponse =
          await flightAvailabilityService.checkFlightAvailability(
        token: token,
        origin: origin,
        destination: destination,
        departureDateTime:
            _formatDateTime(flightDateController.departureDate.value),
        returnDateTime: flightDateController.tripType.value == 'Return'
            ? _formatDateTime(flightDateController.returnDate.value)
            : null,
        cabinClass: travelersController.travelClass.value,
        adultCount: travelersController.adultCount.value,
        childCount: travelersController.childrenCount.value,
        infantCount: travelersController.infantCount.value,
        flights: flightSegments,
      );

      if (availabilityResponse != null) {
        print(availabilityResponse);
        print('Package availability confirmed');
        // Handle successful availability check

        if (flightController.currentScenario.value == FlightScenario.oneWay ||
            !isAnyFlightRemaining) {
          Get.to(() => ReviewTripPage(isMulti: false, flight: flight));
        } else {
          flightController.isSelectingFirstFlight.value = false;
          Get.back();
        }
      }
    } catch (e) {
      print('Error checking flight package availability: $e');
      Get.snackbar(
        'Error',
        'Unable to check package availability. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:01';
  }
}

class FlightAvailabilityService {
  final Dio dio;
  static const String baseUrl = 'https://api.havail.sabre.com';

  FlightAvailabilityService({Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              validateStatus: (status) => true,
            ));

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
          "ClassOfService": flight['ClassOfService'] ?? 'L',
          "Number": flight['Number'],
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
            "SeatsRequested": [adultCount + childCount],
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

      print('Request Body:');
      _printJsonPretty(requestData);

      final response = await dio.post(
        '/v4/shop/flights/revalidate',
        options: Options(headers: headers),
        data: requestData,
      );

      if (response.statusCode == 200) {
        _printJsonPretty(response.data);

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
}
