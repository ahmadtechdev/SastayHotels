import 'package:flutter/material.dart';

import '../../../widgets/colors.dart';
import '../booking_card.dart';
import 'guests/guests_field.dart';


class HotelForm extends StatefulWidget {
  const HotelForm({super.key});

  @override
  State<HotelForm> createState() => _HotelFormState();
}

class _HotelFormState extends State<HotelForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination Field
        const CustomTextField(
          hintText: 'Enter City Name',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 16),
        // Check-in/Check-out Date
        DateSelectionField(
          initialDate: DateTime.now(),
          hintText: 'Check-in',
        ),
        const SizedBox(height: 8),
        DateSelectionField(
          initialDate: DateTime.now().add(const Duration(days: 1)),
          hintText: 'Check-out',
        ),
        const SizedBox(height: 16),
        // Guests and Rooms Field
        const GuestsField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Trigger hotel search
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Text(
            'Search Hotels',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}