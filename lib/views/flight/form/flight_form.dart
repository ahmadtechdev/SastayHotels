import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../widgets/colors.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../../../../widgets/date_selection.dart';
import '../../../../../widgets/snackbar.dart';

import '../search_flights/search_flights.dart';
import 'controllers/flight_search_controller.dart';

import 'controllers/flight_date_controller.dart';
import 'travelers/travelers_field.dart';
import 'trip_type/trip_type_selector.dart';

class FlightForm extends StatelessWidget {
  FlightForm({super.key}) {
    // Initialize the controller
    Get.put(FlightDateController());
  }

  @override
  Widget build(BuildContext context) {
    final flightDateController = Get.find<FlightDateController>();
    final searchController = Get.put(FlightSearchController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Type Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: TripTypeSelector(
            onTripTypeChanged: (selectedType) {
              flightDateController.updateTripType(selectedType);
              // Clear routes when trip type changes
              searchController.clearRoutes();
            },
          ),
        ),
        const SizedBox(height: 16),

        // Multi-City Flights
        Obx(() => flightDateController.tripType.value == 'Multi City'
            ? Column(
            children: [
              GetBuilder<FlightDateController>(
                builder: (controller) => ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.flights.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Flight ${index + 1}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (index >= 2)
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () {
                                  controller.removeFlight(index);
                                  // Also update the search controller lists
                                  if (index <
                                      searchController.origins.length) {
                                    searchController.origins
                                        .removeAt(index);
                                  }
                                  if (index <
                                      searchController
                                          .destinations.length) {
                                    searchController.destinations
                                        .removeAt(index);
                                  }
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: 'Enter departure city',
                          icon: Icons.location_on,
                          fieldType: FieldType.departure,
                          initialValue: controller.flights[index]['origin'],
                          onCitySelected: (name, code) {
                            // Update both controllers with city name and code
                            controller.flights[index]['origin'] = name;
                            searchController.updateRoute(index,
                                origin: code, originName: name);
                            controller.update();
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: 'Enter destination city',
                          icon: Icons.location_on,
                          fieldType: FieldType.destination,
                          initialValue: controller.flights[index]
                          ['destination'],
                          onCitySelected: (name, code) {
                            // Update both controllers with city name and code
                            controller.flights[index]['destination'] = name;
                            searchController.updateRoute(index,
                                destination: code, destinationName: name);
                            controller.update();
                          },
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Departure Date",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: TColors.grey,
                              ),
                            ),
                            DateSelectionField(
                              initialDate: controller.flights[index]
                              ['date'],
                              fontSize: 12,
                              onDateChanged: (date) {
                                controller.updateMultiCityFlightDate(
                                    index, date);
                              },
                              firstDate: DateTime.now(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
              // Find the TextButton.icon for "Add Flights" and update the onPressed handler:

              TextButton.icon(
                onPressed: () {
                  if (flightDateController.flights.length < 4) {
                    // Get the last flight's date
                    final lastFlightIndex = flightDateController.flights.length - 1;
                    DateTime? lastDate = flightDateController.flights[lastFlightIndex]['date'];

                    // Create new date one day after the last flight
                    DateTime newDate = lastDate != null
                        ? lastDate.add(const Duration(days: 1))
                        : DateTime.now();

                    // Add new flight with incremented date
                    flightDateController.addFlight(initialDate: newDate);

                    // Auto-populate origin from previous destination
                    int newIndex = flightDateController.flights.length - 1;
                    if (newIndex > 0 && searchController.destinations.length > newIndex - 1) {
                      String prevDestCode = searchController.destinations[newIndex - 1];
                      String prevDestName = flightDateController.flights[newIndex - 1]['destination'] ?? '';

                      if (prevDestCode.isNotEmpty) {
                        searchController.updateRoute(newIndex,
                            origin: prevDestCode, originName: prevDestName);
                      }
                    }
                    flightDateController.update();
                  } else {
                    CustomSnackBar(
                      message: "You can select up to 4 flights for a multi-city trip.",
                      backgroundColor: TColors.third,
                    ).show();
                  }
                },
                icon: const Icon(Icons.add, color: TColors.primary),
                label: const Text(
                  'Add Flights',
                  style: TextStyle(color: TColors.primary),
                ),
              ), ] )
            : Column(
          children: [
            CustomTextField(
              hintText: 'Enter departure city',
              icon: Icons.location_on,
              fieldType: FieldType.departure,
              onCitySelected: (name, code) {
                // Update the origin in the search controller for index 0
                searchController.updateRoute(0,
                    origin: code, originName: name);
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Enter destination city',
              icon: Icons.location_on,
              fieldType: FieldType.destination,
              onCitySelected: (name, code) {
                // Update the destination in the search controller for index 0
                searchController.updateRoute(0,
                    destination: code, destinationName: name);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Departure Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Obx(() => DateSelectionField(
                        initialDate:
                        flightDateController.departureDate.value,
                        fontSize: 12,
                        onDateChanged: (date) {
                          flightDateController
                              .updateDepartureDate(date);
                        },
                        firstDate: DateTime.now(),
                      )),
                    ],
                  ),
                ),
                if (flightDateController.tripType.value == 'Return') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Return Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Obx(() => DateSelectionField(
                          initialDate:
                          flightDateController.returnDate.value,
                          fontSize: 12,
                          onDateChanged: (date) {
                            flightDateController
                                .updateReturnDate(date);
                          },
                          minDate:
                          flightDateController.getMinReturnDate(),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        )),
        const SizedBox(height: 16),
        const TravelersField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            await searchController.searchFlights();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Obx(() {
            return searchController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'Search Flights',
              style: TextStyle(color: Colors.white),
            );
          }),
        ),
      ],
    );
  }
}