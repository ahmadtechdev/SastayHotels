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

                // if (flightController.currentScenario.value ==
                //     FlightScenario.oneWay ||
                //     !isAnyFlightRemaining) {
                //   // Pass the selected flight to ReviewTripPage
                //   Get.to(() => ReviewTripPage(
                //     isMulti: false,
                //     flight: flight, // Pass the selected flight here
                //   ));
                // } else {
                //   flightController.isSelectingFirstFlight.value = false;
                //   // Get.back();
                // }
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
      final travelersController = Get.find<TravelersController>();
      final flightController = Get.find<FlightController>();

      // Extract flight segments and organize them based on the flight scenario
      final List<Map<String, dynamic>> originDestinations = [];

      // Process all flight segments for each leg schedule
      for (var legIndex = 0;
          legIndex < flight.legSchedules.length;
          legIndex++) {
        final legSchedule = flight.legSchedules[legIndex];
        final List<Map<String, dynamic>> flightSegments = [];

        // Process all schedules within this leg
        for (var schedule in legSchedule['schedules']) {
          final carrier = schedule['carrier'];
          flightSegments.add({
            "ClassOfService": flight.cabinClass,
            "Number": carrier['marketingFlightNumber'],
            "DepartureDateTime": schedule['departure']['dateTime'],
            "ArrivalDateTime": schedule['arrival']['dateTime'],
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

        // Create origin destination information for this leg
        final originDestination = {
          "RPH": (legIndex + 1).toString(),
          "DepartureDateTime": legSchedule['departure']['dateTime'],
          "OriginLocation": {
            "LocationCode": legSchedule['departure']['airport']
          },
          "DestinationLocation": {
            "LocationCode": legSchedule['arrival']['airport']
          },
          "TPA_Extensions": {
            "Flight": flightSegments,
            "SegmentType": {"Code": "O"}
          }
        };

        originDestinations.add(originDestination);
      }

      // Create the request body
      final requestBody = {
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
            "SeatsRequested": [
              travelersController.adultCount.value +
                  travelersController.childrenCount.value
            ],
            "AirTravelerAvail": [
              {
                "PassengerTypeQuantity": [
                  if (travelersController.adultCount.value > 0)
                    {
                      "Code": "ADT",
                      "Quantity": travelersController.adultCount.value
                    },
                  if (travelersController.childrenCount.value > 0)
                    {
                      "Code": "CHD",
                      "Quantity": travelersController.childrenCount.value
                    },
                  if (travelersController.infantCount.value > 0)
                    {
                      "Code": "INF",
                      "Quantity": travelersController.infantCount.value
                    }
                ]
              }
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
          "OriginDestinationInformation": originDestinations,
          "TPA_Extensions": {
            "IntelliSellTransaction": {
              "RequestType": {"Name": "50ITINS"}
            }
          }
        }
      };

      // Check flight availability
      final response = await apiService.checkFlightAvailability(
        type: flightController.currentScenario.value.index,
        flightSegments: originDestinations
            .expand((od) =>
                (od['TPA_Extensions']['Flight'] as List<Map<String, dynamic>>))
            .toList(),
        adult: travelersController.adultCount.value,
        child: travelersController.childrenCount.value,
        infant: travelersController.infantCount.value,
        requestBody: requestBody,
      );

      // Handle the response and navigation
      if (response.containsKey('groupedItineraryResponse')) {

          Get.to(() => ReviewTripPage(
                isMulti: false,
                flight: flight,
              ));

      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error checking flight package availability: $e');
      Get.snackbar(
        'Error',
        'This flight package is no longer available. Please select another option.',
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
