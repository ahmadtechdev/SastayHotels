import 'package:flight_bocking/home_search/search_hotels/search_hotel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/colors.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/date_selection.dart';
import 'hotel_date_controller.dart';
import 'guests/guests_field.dart';

class HotelForm extends StatelessWidget {
  HotelForm({super.key}) {
    // Initialize the controller
    Get.put(HotelDateController());
  }

  @override
  Widget build(BuildContext context) {
    final hotelDateController = Get.find<HotelDateController>();
    final cityController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Enter City Name',
          icon: Icons.location_on,
          controller: cityController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check In",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Obx(() => DateSelectionField(
                        initialDate: hotelDateController.checkInDate.value,
                        fontSize: 12,
                        onDateChanged: (date) {
                          hotelDateController.updateCheckInDate(date);
                        },
                        firstDate: DateTime.now(),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Check Out",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Obx(() => DateSelectionField(
                        initialDate: hotelDateController.checkOutDate.value,
                        fontSize: 12,
                        onDateChanged: (date) {
                          hotelDateController.updateCheckOutDate(date);
                        },
                        minDate: hotelDateController.getMinCheckOutDate(),
                      )),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const GuestsField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Get.to(HotelScreen());

            // // Access dates from controller when searching
            // final checkIn = hotelDateController.checkInDate.value;
            // final checkOut = hotelDateController.checkOutDate.value;
            // Implement search logic
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
