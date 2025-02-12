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
          isAnyFlightRemaining ? 'Select Return Flight Package' : 'Select Flight Package',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFlightInfo(),
            _buildPackagesList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                flight.imgPath,
                height: 32,
                width: 50,
              ),
              const SizedBox(width: 12),
              Text(
                flight.airline,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight.departureTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  Text(
                    flight.from,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    flight.duration,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(
                      Icons.flight_takeoff,
                      color: TColors.primary,
                    ),
                  ),
                  Text(
                    flight.isNonStop ? 'Nonstop' : 'With Stops',
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    flight.arrivalTime,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  Text(
                    flight.to,
                    style: const TextStyle(
                      fontSize: 14,
                      color: TColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList() {
    return Expanded(
      child: Column(
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
      ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {

                // Example usage in flight_package.dart
                onSelectPackage();

                if (flightController.currentScenario.value == FlightScenario.oneWay ||
                    !isAnyFlightRemaining) {
                  Get.to(() => const ReviewTripPage(isMulti: false));
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
                isAnyFlightRemaining ? 'Select Return Package' : 'Select Package',
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
  void onSelectPackage() async {
    try {
      final apiService = ApiServiceFlight();
      final token = await apiService.getValidToken() ?? await apiService.generateToken();

      // Get origin and destination from the selected flight
      final origin = flight.from;
      final destination = flight.to;

      // Clean location codes - remove any spaces and brackets
      String cleanValue(String value) {
        return value.split('(').first.trim().toUpperCase();
      }

      final cleanOrigin = cleanValue(origin);
      final cleanDestination = cleanValue(destination);

      // Get dates from the flight date controller
      final departureDate = _formatDateTime(flightDateController.departureDate.value);
      final returnDate = flightDateController.tripType.value == 'Return'
          ? _formatDateTime(flightDateController.returnDate.value)
          : '';

      // Get passenger counts from travelers controller
      final adultCount = travelersController.adultCount.value;
      final childCount = travelersController.childrenCount.value;
      final infantCount = travelersController.infantCount.value;

      // Get cabin class from travelers controller
      final cabinClass = travelersController.travelClass.value;

      // Create flight segments based on the selected flight
      final List<Map<String, dynamic>> flightSegments = [];

      // Add outbound flight segment
      flightSegments.add({
        "ClassOfService": flight.classOfService,
        "Number": flight.flightNumber,
        "DepartureDateTime": flight.departureDateTime,
        "ArrivalDateTime": flight.arrivalDateTime,
        "Type": "A",
        "OriginLocation": {"LocationCode": cleanOrigin},
        "DestinationLocation": {"LocationCode": cleanDestination},
        "Airline": {
          "Operating": flight.operatingCarrier,
          "Marketing": flight.marketingCarrier
        }
      });

      // If it's a return flight and we're checking the second flight
      if (!isAnyFlightRemaining && flightController.selectedFirstFlight.value != null) {
        final firstFlight = flightController.selectedFirstFlight.value!;
        flightSegments.add({
          "ClassOfService": firstFlight.classOfService,
          "Number": firstFlight.flightNumber,
          "DepartureDateTime": firstFlight.departureDateTime,
          "ArrivalDateTime": firstFlight.arrivalDateTime,
          "Type": "A",
          "OriginLocation": {"LocationCode": destination},
          "DestinationLocation": {"LocationCode": origin},
          "Airline": {
            "Operating": firstFlight.operatingCarrier,
            "Marketing": firstFlight.marketingCarrier
          }
        });
      }

      final availabilityResponse = await apiService.checkFlightPackageAvailability(
        token: token,
        origin: origin,
        destination: destination,
        departureDateTime: departureDate,
        returnDateTime: returnDate,
        cabinClass: cabinClass,
        adultCount: adultCount,
        childCount: childCount,
        infantCount: infantCount,
        flights: flightSegments,
      );

      if (availabilityResponse != null) {
        // Handle successful availability check
        // You might want to update the UI or proceed with booking
        print('Package availability confirmed');
      }
    } catch (e) {
      print('Error checking flight package availability: $e');
      // Show error message to user
      Get.snackbar(
        'Error',
        'Unable to check package availability. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:01';
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
}