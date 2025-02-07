import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/colors.dart';

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
      child: ListView.builder(
        // scrollDirection: Axis.horizontal,
        itemCount: flight.packages.length,
        itemBuilder: (context, index) {
          final package = flight.packages[index];
          return _buildPackageCard(package);
        },
      ),
    );
  }

  Widget _buildPackageCard(FlightPackageInfo package) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(20),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: TColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.cabinName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background,
                  ),
                ),
                Text(
                  '${package.currency} ${package.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPackageDetail(
                  Icons.airline_seat_recline_normal,
                  'Cabin',
                  package.cabinName,
                ),
                _buildPackageDetail(
                  Icons.luggage,
                  'Baggage',
                  '${package.baggageAllowance.pieces} pieces',
                ),
                _buildPackageDetail(
                  Icons.restaurant,
                  'Meal',
                  package.mealCode == 'M' ? 'Meal Included' : 'No Meal',
                ),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
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