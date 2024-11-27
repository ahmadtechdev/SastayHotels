import 'package:flight_bocking/home_search/search_flights/flight_package/package_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/colors.dart';
import '../review_flight/review_flight.dart';
import '../search_flight_utils/filter_modal.dart';
import '../search_flight_utils/flight_controller.dart';
import '../search_flights.dart';
import 'package_controller.dart';

class PackageSelectionDialog extends StatelessWidget {
  final Flight flight;
  final bool isAnyFlightRemaining;

  PackageSelectionDialog({
    super.key,
    required this.flight,
    required this.isAnyFlightRemaining,
  });
  final packageController = Get.put(PackageController());
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
          icon: const Icon(
            Icons.arrow_back,
          ),
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
                'assets/img/logos/air-arabia.png',
                height: 32,
                width: 50,
              ),
              const SizedBox(width: 12),
              const Text(
                'Fly Jinnah',
                style: TextStyle(
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
                  const Text(
                    '1h 55m',
                    style: TextStyle(
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
                  const Text(
                    'Nonstop',
                    style: TextStyle(
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
      child: Obx(
        () => PageView.builder(
          controller: _pageController,
          itemCount: packageController.packages.length,
          itemBuilder: (context, index) {
            return _buildPackageCard(packageController.packages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildPackageCard(FlightPackage package) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
                  package.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background,
                  ),
                ),
                Text(
                  'PKR ${package.price}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.background,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildPackageDetail(
                    Icons.luggage,
                    'Check-in Baggage',
                    package.checkInBaggage,
                  ),
                  _buildPackageDetail(
                    Icons.cancel_outlined,
                    'Cancellation',
                    package.cancellation,
                  ),
                  _buildPackageDetail(
                    Icons.edit_outlined,
                    'Modification',
                    package.modification,
                  ),
                  _buildPackageDetail(
                    Icons.airline_seat_recline_normal,
                    'Seat',
                    package.seat,
                  ),
                  _buildPackageDetail(
                    Icons.restaurant,
                    'Meal',
                    package.meal,
                  ),
                  if (package.refundPrice != null) _buildRefundBox(package),
                ],
              ),
            ),
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     if(Flight Package){
          //
          //     }
          //     Get.to(() => const ReviewTripPage());
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: TColors.primary,
          //     fixedSize: const Size(double.infinity, 40),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(48),
          //     ),
          //   ),
          //   child: const Text(
          //     'Select Package',
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //       color: TColors.background,
          //     ),
          //   ),
          // ),
          ElevatedButton(
            onPressed: () {
              print(isAnyFlightRemaining);
              if (flightController.currentScenario.value == FlightScenario.oneWay || !isAnyFlightRemaining) {
                // For one-way or first flight selection
                if(flightController.currentScenario.value !=FlightScenario.oneWay){
                  Get.to(() => const ReviewTripPage(isMulti: true,));
                }else{
                  Get.to(() => const ReviewTripPage(isMulti: false,));
                }

              } else {
                // For return flight, go back to select second flight
                flightController.isSelectingFirstFlight.value = false;
                Get.back(); // Go back to flight selection
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              fixedSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(48),
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

  Widget _buildRefundBox(FlightPackage package) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: TColors.primary),
              SizedBox(width: 8),
              Text(
                'SastayHotels Refund',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PKR ${package.refundPrice}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: TColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Modify or cancel your trip for free before departure.',
            style: TextStyle(
              fontSize: 12,
              color: TColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
