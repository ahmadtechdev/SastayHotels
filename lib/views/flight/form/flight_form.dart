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

    // No need for text controllers here since we're handling values directly

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Type Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: TripTypeSelector(
            onTripTypeChanged: (selectedType) {
              flightDateController.updateTripType(selectedType);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Multi-City Flights
        Obx(() => flightDateController.tripType.value == 'Multi City'
            ? Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: flightDateController.flights.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Flight ${index + 1}",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        if (index >= 2)
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.red),
                            onPressed: () =>
                                flightDateController.removeFlight(index),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Enter departure city',
                      icon: Icons.location_on,
                      fieldType: FieldType.departure,
                      onCitySelected: (name, code) {
                        // Store original data
                        flightDateController.flights[index]['origin'] = name;

                        // Update the city code in the search controller
                        searchController.updateRoute(index, origin: code);
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: 'Enter destination city',
                      icon: Icons.location_on,
                      fieldType: FieldType.destination,
                      onCitySelected: (name, code) {
                        // Store original data
                        flightDateController.flights[index]['destination'] = name;

                        // Update the city code in the search controller
                        searchController.updateRoute(index, destination: code);
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
                          initialDate: flightDateController.flights[index]
                          ['date'],
                          fontSize: 12,
                          onDateChanged: (date) {
                            flightDateController
                                .updateMultiCityFlightDate(index, date);
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
            TextButton.icon(
              onPressed: () {
                if (flightDateController.flights.length < 4) {
                  flightDateController.addFlight();
                } else {
                  CustomSnackBar(
                    message:
                    "You can select up to 4 flights for a multi-city trip.",
                    backgroundColor: TColors.third,
                  ).show();
                }
              },
              icon: const Icon(Icons.add, color: TColors.primary),
              label: const Text(
                'Add Flights',
                style: TextStyle(color: TColors.primary),
              ),
            ),
          ],
        )
            : Column(
          children: [
            CustomTextField(
              hintText: 'Enter departure city',
              icon: Icons.location_on,
              fieldType: FieldType.departure,
              onCitySelected: (name, code) {
                // Update the origin in the search controller for index 0
                searchController.updateRoute(0, origin: code);
              },
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: 'Enter destination city',
              icon: Icons.location_on,
              fieldType: FieldType.destination,
              onCitySelected: (name, code) {
                // Update the destination in the search controller for index 0
                searchController.updateRoute(0, destination: code);
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