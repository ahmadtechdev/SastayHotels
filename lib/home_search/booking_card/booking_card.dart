import 'package:flight_bocking/home_search/booking_card/tour.dart';
import 'package:flutter/material.dart';

import '../../widgets/colors.dart';
import 'forms/flight/flight_form.dart';
import 'forms/hotel/hotel_form.dart';

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
              if (selectedType == 'Tours') const ToursPage(),
            ],
          ),
        ),
      ),
    );
  }
}
