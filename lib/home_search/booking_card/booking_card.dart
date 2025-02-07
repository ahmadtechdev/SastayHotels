
import 'package:flutter/material.dart';

import '../../views/cars/search_cars/search_cars.dart';
import '../../views/flight/form/flight_form.dart';
import '../../views/hotel/hotel/hotel_form.dart';
import '../../views/tour/search_tour/tour_form.dart';
import '../../widgets/colors.dart';


import 'type_selector/type_selector.dart';

class BookingCard extends StatefulWidget {
  const BookingCard({super.key});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  String selectedType = 'Flights'; // Default type

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 40),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type Selector
              TypeSelector(
                onTypeChanged: (String type) {
                  setState(() {
                    selectedType = type;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Show the relevant form based on the selected type
              if (selectedType == 'Flights') FlightForm(),
              if (selectedType == 'Hotels') HotelForm(),
              if (selectedType == 'Tours') const ToursForm(),
              if (selectedType == 'Cars') const SearchCars(),
            ],
          ),
        ),
      ),
    );
  }
}
