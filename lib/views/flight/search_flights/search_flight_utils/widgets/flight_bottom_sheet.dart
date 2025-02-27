import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../widgets/colors.dart';
import '../flight_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  final FlightController controller;

  const FilterBottomSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceRange(),
                    const Divider(),
                    _buildRefundableOptions(),
                    const Divider(),
                    _buildStopOptionFilter(),
                    const Divider(),
                    _buildAirlinesFilter(),
                    const Divider(),
                    _buildTimeRangeFilter(true), // Departure
                    const Divider(),
                    _buildTimeRangeFilter(false), // Arrival
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Range',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final range = controller.filterState.value.priceRange;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.selectedCurrency.value} ${range.start.round()}',
                    style: const TextStyle(color: TColors.grey),
                  ),
                  Text(
                    '${controller.selectedCurrency.value} ${range.end.round()}',
                    style: const TextStyle(color: TColors.grey),
                  ),
                ],
              ),
              RangeSlider(
                values: range,
                min: controller.flights
                    .map((f) => f.price)
                    .reduce((a, b) => a < b ? a : b),
                max: controller.flights
                    .map((f) => f.price)
                    .reduce((a, b) => a > b ? a : b),
                activeColor: TColors.primary,
                inactiveColor: TColors.grey.withOpacity(0.2),
                onChanged: controller.updatePriceRange,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRefundableOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refundable',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() {
          return Column(
            children: [
              CheckboxListTile(
                title: const Text('All'),
                value: controller.filterState.value.isRefundableAll,
                activeColor: TColors.primary,
                onChanged: (value) {
                  controller.toggleRefundableAll(value ?? false);
                },
              ),
              CheckboxListTile(
                title: const Text('Refundable'),
                value: controller.filterState.value.isRefundable,
                activeColor: TColors.primary,
                onChanged: (value) {
                  controller.toggleRefundable(value ?? false);
                  controller.filterState.value =
                      controller.filterState.value.copyWith(
                    isRefundableAll: false,
                    isNonRefundable: false,
                  );
                },
              ),
              CheckboxListTile(
                title: const Text('Non-Refundable'),
                value: controller.filterState.value.isNonRefundable,
                activeColor: TColors.primary,
                onChanged: (value) {
                  controller.toggleNonRefundable(value ?? false);
                  controller.filterState.value =
                      controller.filterState.value.copyWith(
                    isRefundableAll: false,
                    isRefundable: false,
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }

  // Modify the following methods in your FilterBottomSheet class

Widget _buildStopOptionFilter() {
  return Obx(() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stops',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Add "All" as the first option
        CheckboxListTile(
          title: const Text('All'),
          value: controller.filterState.value.selectedStops.contains('All'),
          activeColor: TColors.primary,
          onChanged: (value) => controller.toggleStopOption('All', value ?? false),
        ),
        CheckboxListTile(
          title: const Text('Non Stop'),
          value: controller.filterState.value.selectedStops.contains('0 Stops'),
          activeColor: TColors.primary,
          onChanged: (value) => controller.toggleStopOption('0 Stops', value ?? false),
        ),
        CheckboxListTile(
          title: const Text('1 Stop'),
          value: controller.filterState.value.selectedStops.contains('1 Stop'),
          activeColor: TColors.primary,
          onChanged: (value) => controller.toggleStopOption('1 Stop', value ?? false),
        ),
        CheckboxListTile(
          title: const Text('2 Stops'),
          value: controller.filterState.value.selectedStops.contains('2 Stops'),
          activeColor: TColors.primary,
          onChanged: (value) => controller.toggleStopOption('2 Stops', value ?? false),
        ),
      ],
    );
  });
}

Widget _buildAirlinesFilter() {
  final airlines = controller.flights.map((f) => f.airline).toSet().toList();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Airlines',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      // Add "All Airlines" as the first option
      Obx(() => CheckboxListTile(
        title: const Text('All Airlines'),
        value: controller.filterState.value.selectedAirlines.contains('All Airlines'),
        activeColor: TColors.primary,
        onChanged: (_) => controller.toggleAirline('All Airlines'),
      )),
      // List individual airlines
      ...airlines.map((airline) => Obx(() => CheckboxListTile(
        title: Text(airline),
        value: controller.filterState.value.selectedAirlines.contains(airline),
        activeColor: TColors.primary,
        onChanged: (_) => controller.toggleAirline(airline),
      ))),
    ],
  );
}

Widget _buildTimeRangeFilter(bool isDeparture) {
  final timeRanges = [
    '00:00 - 06:00',
    '06:00 - 12:00',
    '12:00 - 18:00',
    '18:00 - 00:00'
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        isDeparture ? 'Departure Time' : 'Arrival Time',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      // Add "All Times" as the first option
      Obx(() {
        final selectedRanges = isDeparture
            ? controller.filterState.value.departureTimeRanges
            : controller.filterState.value.arrivalTimeRanges;
        return CheckboxListTile(
          title: const Text('All Times'),
          value: selectedRanges.contains('All Times'),
          activeColor: TColors.primary,
          onChanged: (_) => controller.toggleTimeRange('All Times', isDeparture),
        );
      }),
      // List individual time ranges
      ...timeRanges.map((range) => Obx(() {
        final selectedRanges = isDeparture
            ? controller.filterState.value.departureTimeRanges
            : controller.filterState.value.arrivalTimeRanges;
        return CheckboxListTile(
          title: Text(range),
          value: selectedRanges.contains(range),
          activeColor: TColors.primary,
          onChanged: (_) => controller.toggleTimeRange(range, isDeparture),
        );
      })),
    ],
  );
}

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: TColors.background,
        border: Border(
          top: BorderSide(color: TColors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                controller.resetFilters();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: const BorderSide(color: TColors.primary),
              ),
              child: const Text('Clear'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                backgroundColor: TColors.primary,
              ),
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
