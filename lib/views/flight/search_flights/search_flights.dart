import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/colors.dart';
import 'search_flight_utils/flight_controller.dart';
import 'search_flight_utils/widgets/currency_dialog.dart';
import 'search_flight_utils/widgets/flight_bottom_sheet.dart';
import 'search_flight_utils/widgets/flight_card.dart';

enum FlightScenario { oneWay, returnFlight, multiCity }

class ReturnCaseScenario extends StatelessWidget {
  final String stepNumber;
  final String stepText;
  final bool isActive;

  const ReturnCaseScenario({
    super.key,
    required this.stepNumber,
    required this.stepText,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isActive ? TColors.primary : TColors.grey,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: TColors.background,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            stepText,
            style: TextStyle(
              color: isActive ? TColors.primary : TColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class FlightBookingPage extends StatelessWidget {
  final FlightScenario scenario;
  final FlightController controller = Get.put(FlightController());

  FlightBookingPage({super.key, required this.scenario}) {
    controller.setScenario(scenario);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: TColors.background2,
      appBar: AppBar(
        surfaceTintColor: TColors.background,
        backgroundColor: TColors.background,
        leading: const BackButton(),
        title: Obx(() {
          // Get the first flight to extract route information
          final firstFlight = controller.flights.isEmpty ? null : controller.flights[0];

          // if (firstFlight == null) {
          //   return const CircularProgressIndicator();
          // }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Text(
              //       '${searchConroller.origins.first} ',
              //       style: const TextStyle(
              //         fontSize: 16,
              //         color: TColors.text,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //     const Icon(
              //       Icons.swap_horiz,
              //       size: 20,
              //       color: TColors.text,
              //     ),
              //     Text(
              //       ' ${searchConroller.origins.last}',
              //       style: const TextStyle(
              //         fontSize: 16,
              //         color: TColors.text,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                children: [
                  Text(
                    '${controller.flights.length} Flights Found',
                    style: const TextStyle(
                      fontSize: 16,
                      color: TColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // GestureDetector(
                  //   onTap: () {
                  //     Get.off(() => const HomeScreen());
                  //   },
                  //   child: const Row(
                  //     children: [
                  //       Icon(
                  //         Icons.edit,
                  //         size: 16,
                  //         color: TColors.text,
                  //       ),
                  //       SizedBox(width: 4),
                  //       Text(
                  //         'Change',
                  //         style: TextStyle(
                  //           fontSize: 16,
                  //           color: TColors.text,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ],
          );
        }),
        actions: [
          GetX<FlightController>(
            builder: (controller) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CurrencyDialog(controller: controller),
                );
              },
              child: Text(
                controller.selectedCurrency.value,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [

          _buildFilterSection(),
          _buildFlightList(),
        ],
      ),
    );
  }


  Widget _buildFilterSection() {
    return Container(
      color: TColors.background,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() => _filterButton(
                'Suggested', controller.sortType.value == 'Suggested')),
            Obx(() => _filterButton(
                'Cheapest', controller.sortType.value == 'Cheapest')),
            Obx(() =>
                _filterButton('Fastest', controller.sortType.value == 'Fastest')),
            OutlinedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: Get.context!,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => FilterBottomSheet(controller: controller),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightList() {
    return Expanded(
      child: Obx(() {
        if (controller.filteredFlights.isEmpty) {
          return const Center(
            child: Text(
              'No flights match your criteria.',
              style: TextStyle(color: TColors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.filteredFlights.length,
          itemBuilder: (context, index) {
            final flight = controller.filteredFlights[index];
            return GestureDetector(
              onTap: () => controller.handleFlightSelection(flight),
              child: FlightCard(flight: flight),
            );
          },
        );
      }),
    );
  }

  Widget _filterButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {
        controller.updateSortType(text);
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : TColors.grey,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

