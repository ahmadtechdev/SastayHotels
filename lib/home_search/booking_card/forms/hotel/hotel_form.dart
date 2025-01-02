import 'package:flight_bocking/home_search/search_hotels/search_hotel.dart';
import 'package:flight_bocking/home_search/search_hotels/search_hotle_Controler.dart';
import 'package:flight_bocking/widgets/date_range_slector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/api_service.dart';
import '../../../../widgets/colors.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../../../widgets/loading_dailog.dart';
import 'guests/guests_controller.dart';
import 'hotel_date_controller.dart';
import 'guests/guests_field.dart';

class HotelForm extends StatelessWidget {
  HotelForm({super.key}) {
    // Initialize the controller
    Get.put(HotelDateController());
  }

  @override
  Widget build(BuildContext context) {
    // final hotelDateController = Get.put(AboutDialog());
    final cityController = TextEditingController();
    SearchHotelController searchhotelController =
    Get.put(SearchHotelController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Enter City Name',
          icon: Icons.location_on,
          controller: cityController,
        ),
        const SizedBox(height: 16),
        Obx(
              () => CustomDateRangeSelector(
            dateRange: searchhotelController.dateRange.value,
            onDateRangeChanged: searchhotelController.updateDateRange,
            nights: searchhotelController.nights.value,
            onNightsChanged: searchhotelController.updateNights,
          ),
        ),
        // Row(
        //   children: [
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Text(
        //             "Check In",
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //           Obx(() => DateSelectionField(
        //                 initialDate: hotelDateController.checkInDate.value,
        //                 fontSize: 12,
        //                 onDateChanged: (date) {
        //                   hotelDateController.updateCheckInDate(date);
        //                 },
        //                 firstDate: DateTime.now(),
        //               )),
        //         ],
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Text(
        //             "Check Out",
        //             style: TextStyle(fontWeight: FontWeight.bold),
        //           ),
        //           Obx(() => DateSelectionField(
        //                 initialDate: hotelDateController.checkOutDate.value,
        //                 fontSize: 12,
        //                 onDateChanged: (date) {
        //                   hotelDateController.updateCheckOutDate(date);
        //                 },
        //                 minDate: hotelDateController.getMinCheckOutDate(),
        //               )),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 16),
        const GuestsField(),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            // Show loading dialog
            Get.dialog(
              const LoadingDialog(),
              barrierDismissible: false,
            );

            final hotelDateController = Get.find<HotelDateController>();
            final guestsController = Get.find<GuestsController>();

            // Prepare API parameters
            String destinationCode = "160-0";
            String countryCode = "AE";
            String nationality = "AE";
            String currency = "USD";
            String checkInDate =
            hotelDateController.checkInDate.value.toIso8601String();
            String checkOutDate =
            hotelDateController.checkOutDate.value.toIso8601String();
            List<Map<String, dynamic>> rooms = List.generate(
              guestsController.roomCount.value,
                  (index) => {
                "RoomIdentifier": index + 1,
                "Adult": guestsController.adultsPerRoom[index],
              },
            );

            try {
              // Call the API
              await ApiService().fetchHotels(
                destinationCode: destinationCode,
                countryCode: countryCode,
                nationality: nationality,
                currency: currency,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                rooms: rooms,
              );

              // Close loading dialog
              Get.back();

              // Navigate to the hotel listing screen
              Get.to(HotelScreen());
            } catch (e) {
              // Close loading dialog
              Get.back();

              // Show error dialog
              Get.dialog(
                Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            minimumSize: const Size(200, 45),
                          ),
                          child: const Text('OK',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
            }
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
