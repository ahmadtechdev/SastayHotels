import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/colors.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/date_controller.dart';
import '../../../widgets/date_selection.dart';
import 'guests/guests_field.dart';

class HotelForm extends StatelessWidget {
  HotelForm({super.key});

  // Instantiate the DateController
  final DateController dateController = Get.put(DateController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination Field
        CustomTextField(
          hintText: 'Enter City Name',
          icon: Icons.location_on,
        ),
        const SizedBox(height: 16),
        // Check-In/Check-Out Date Fields
        Row(
          children: [
            // Check-In Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Obx(() => DateSelectionField(
                    initialDate: dateController.checkInDate.value,
                    minDate: DateTime.now(),
                    onDateChanged: (selectedDate) {
                      dateController.updateCheckInDate(selectedDate);
                    },
                  )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Check-Out Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Obx(() => DateSelectionField(
                    initialDate: dateController.checkOutDate.value,
                    minDate: dateController.checkInDate.value,
                    onDateChanged: (selectedDate) {
                      dateController.updateCheckOutDate(selectedDate);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Guests and Rooms Field
        const GuestsField(),
        const SizedBox(height: 16),
        // Search Hotels Button
        ElevatedButton(
          onPressed: () {
            // Trigger hotel search with selected dates
            print("Check-In: ${dateController.checkInDate.value}");
            print("Check-Out: ${dateController.checkOutDate.value}");
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