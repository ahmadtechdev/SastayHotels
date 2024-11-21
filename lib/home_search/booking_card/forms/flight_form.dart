import 'package:flutter/material.dart';

import '../../../widgets/colors.dart';
import '../../../widgets/snackbar.dart';
import '../booking_card.dart';
import '../trip_type/trip_type_selector.dart';
import 'travelers/travelers_field.dart';

class FlightForm extends StatefulWidget {
  const FlightForm({super.key});

  @override
  State<FlightForm> createState() => _FlightFormState();
}

class _FlightFormState extends State<FlightForm> {
  String tripType = 'One-way'; // Default trip type
  List<Map<String, dynamic>> flights = [
    {'from': '', 'to': '', 'date': DateTime.now()},
    // Flight 1
    {'from': '', 'to': '', 'date': DateTime.now().add(const Duration(days: 1))},
    // Flight 2
  ];

  void addFlight() {
    setState(() {
      if (flights.length < 4) {
        flights.add({
          'from': '',
          'to': '',
          'date': DateTime.now().add(Duration(days: flights.length)),
        });
      } else {
        CustomSnackBar(message: "You can select up to 4 flights for a multi-city trip.", backgroundColor: TColors.third).show();

      }
    });
  }

  void removeFlight(int index) {
    setState(() {
      flights.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trip Type Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: TripTypeSelector(
            onTripTypeChanged: (selectedType) {
              setState(() {
                tripType = selectedType;
                if (tripType != 'Multi City') {
                  flights = [
                    {'from': '', 'to': '', 'date': DateTime.now()},
                    {'from': '', 'to': '', 'date': DateTime.now().add(const Duration(days: 1))},
                  ];
                }
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        // Multi-City Flights
        if (tripType == 'Multi City')
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: flights.length,
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
                          if (index >= 2) // Show remove button for 3rd flight onward
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => removeFlight(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: 'Enter departure city',
                        icon: Icons.location_on,
                        initialValue: flights[index]['from'],
                        onChanged: (value) {
                          setState(() {
                            flights[index]['from'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        hintText: 'Enter destination city',
                        icon: Icons.location_on,
                        initialValue: flights[index]['to'],
                        onChanged: (value) {
                          setState(() {
                            flights[index]['to'] = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      DateSelectionField(
                        initialDate: flights[index]['date'],
                        onDateChanged: (date) {
                          setState(() {
                            flights[index]['date'] = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
              TextButton.icon(
                onPressed: addFlight,
                icon: const Icon(Icons.add, color: TColors.primary),
                label: const Text(
                  'Add destination',
                  style: TextStyle(color: TColors.primary),
                ),
              ),
            ],
          ),
        if (tripType != 'Multi City') ...[
          const CustomTextField(
            hintText: 'Enter departure city',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 8),
          const CustomTextField(
            hintText: 'Enter destination city',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 16),
          DateSelectionField(initialDate: DateTime.now()),
          if (tripType == 'Return') ...[
            const SizedBox(height: 8),
            DateSelectionField(
              initialDate: DateTime.now().add(const Duration(days: 7)),
            ),
          ],
        ],
        const SizedBox(height: 16),
        // Travelers Field
        const TravelersField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Trigger search
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text(
            'Search Flights',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}