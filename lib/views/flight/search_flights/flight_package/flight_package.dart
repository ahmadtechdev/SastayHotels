
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/widgets/flight_card.dart';
import 'package:flight_bocking/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/api_service_flight.dart';
import '../../../../widgets/colors.dart';

import '../../form/controllers/flight_date_controller.dart';
import '../../form/travelers/traveler_controller.dart';
import '../review_flight/review_flight.dart';
import '../search_flight_utils/filter_modal.dart';
import '../search_flight_utils/flight_controller.dart';
import 'package_modal.dart';

class PackageSelectionDialog extends StatelessWidget {
  final Flight flight;
  final bool isAnyFlightRemaining;
  // final List<Map<String, dynamic>> pricingInformation; // Add this parameter

  PackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isAnyFlightRemaining,
    // required this.pricingInformation, // Add this parameter
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
  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P':
        return 'Alcoholic beverages for purchase';
      case 'C':
        return 'Complimentary alcoholic beverages';
      case 'B':
        return 'Breakfast';
      case 'K':
        return 'Continental breakfast';
      case 'D':
        return 'Dinner';
      case 'F':
        return 'Food for purchase';
      case 'G':
        return 'Food/Beverages for purchase';
      case 'M':
        return 'Meal';
      case 'N':
        return 'No meal service';
      case 'R':
        return 'Complimentary refreshments';
      case 'V':
        return 'Refreshments for purchase';
      case 'S':
        return 'Snack';
      default:
        return 'No Meal';
    }
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
                    child: _buildPackageCard(flight.packages[index], index),
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

              physics: const NeverScrollableScrollPhysics(),

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

  // Inside _buildPackageCard method of PackageSelectionDialog
  Widget _buildPackageCard(FlightPackageInfo package, int index) {
    final headerColor = package.isSoldOut
        ? Colors.grey
        : TColors.primary;

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
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  headerColor,
                  headerColor.withOpacity(0.8),
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
                        package.brandDescription.isNotEmpty
                            ? package.brandDescription
                            : package.cabinName,
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
                if (!package.isSoldOut)
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
                if (package.isSoldOut)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TColors.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SOLD OUT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: TColors.background,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      package.isSoldOut
                          ? 'Not available'
                          : '${package.baggageAllowance.type}',
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.restaurant,
                      'Meal',
                      package.isSoldOut
                          ? 'Not available'
                          : getMealInfo(package.mealCode),
                          // : (package.mealCode == 'M' ? 'Meal Included' : 'No Meal'),
                    ),
                    const SizedBox(height: 12),
                    _buildPackageDetail(
                      Icons.event_seat,
                      'Seats Available',
                      package.isSoldOut
                          ? '0'
                          : package.seatsAvailable.toString(),
                    ),
                    _buildPackageDetail(
                      Icons.currency_exchange,
                      'Refundable',
                      package.isSoldOut
                          ? 'Not applicable'
                          : (package.isNonRefundable ? 'Non-Refundable' : 'Refundable'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: package.isSoldOut ? null : () => onSelectPackage(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: package.isSoldOut ? Colors.grey : TColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 2,
              ),
              child: Text(
                package.isSoldOut
                    ? 'Not Available'
                    : (isAnyFlightRemaining ? 'Select Return Package' : 'Select Package'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: package.isSoldOut ? Colors.white70 : TColors.background,
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

  void onSelectPackage(int selectedPackageIndex) async {
    try {
      final apiService = ApiServiceFlight();
      final travelersController = Get.find<TravelersController>();
      final flightController = Get.find<FlightController>();

      // Extract flight segments and organize them based on the flight scenario
      final List<Map<String, dynamic>> originDestinations = [];

      // Process all flight segments for each leg schedule
      for (var legIndex = 0; legIndex < flight.legSchedules.length; legIndex++) {
        final legSchedule = flight.legSchedules[legIndex];
        final List<Map<String, dynamic>> flightSegments = [];

        // Process all schedules within this leg
        for (var i = 0; i < legSchedule['schedules'].length; i++) {
          var schedule = legSchedule['schedules'][i];

          // Access the bookingCode from the current segment index
          final bookingCode = (flight.segmentInfo.length > i) ? flight.segmentInfo[i].bookingCode : '';

          final carrier = schedule['carrier'];
          flightSegments.add({
            "ClassOfService": bookingCode,
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

      // Parse the response to get the pricing information
      flightController.parseApiResponse(response);




      // Handle the response and navigation
      if (response.containsKey('groupedItineraryResponse')) {
        // Get the pricing information from the parsed response
        final pricingInformation = flightController.flights.first.pricingInforArray;

        final validateBasicCode= flightController.flights.first.legSchedules.first['fareBasisCode'];
        final basicCode= flight.legSchedules.first['fareBasisCode'];

        print("Ahmad");
        print(validateBasicCode);
        print(basicCode);
        if(validateBasicCode==basicCode){
          Get.to(() => ReviewTripPage(
            isMulti: false,
            flight: flight,
            pricingInformation: pricingInformation[selectedPackageIndex], // Pass the selected package's pricing information
          ));
        }else{
          CustomSnackBar(message: 'Basic FLight Code Not Matched', backgroundColor: TColors.third).show();
        }

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

}
