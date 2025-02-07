import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/colors.dart';
import '../../../../widgets/snackbar.dart';
import '../../../../widgets/thank_you_screen.dart';
import '../../hotel/guests/guests_controller.dart';
import 'booking_controller.dart';
import 'widget/important_booking_details_card.dart';

class BookingHotelScreen extends StatelessWidget {
  final BookingController bookingController = Get.put(BookingController());
  final GuestsController guestsController = Get.find<GuestsController>();


  BookingHotelScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFAB00),
        title: const Text(
          "Complete Your Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ImportantBookingDetailsCard(),
                  _buildRoomCards(),
                  const SizedBox(height: 20),
                  _buildBookerInfoCard(),
                  const SizedBox(height: 20),
                  _buildSpecialRequestsCard(),
                  const SizedBox(height: 20),
                  _buildTermsAndConditions(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (bookingController.isLoading.value)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFAB00),
              ),
            ),
        ],
      )),
    );
  }

  Widget _buildRoomCards() {
    return Column(
      children: List.generate(
        bookingController.roomGuests.length,
            (roomIndex) => _buildRoomCard(roomIndex),
      ),
    );
  }

  Widget _buildRoomCard(int roomIndex) {
    final roomGuests = bookingController.roomGuests[roomIndex];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Room ${roomIndex + 1}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFAB00),
                  ),
                ),
                const Spacer(),
                _buildBadge("Refundable")
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              roomGuests.adults.length,
                  (adultIndex) => _buildGuestField(
                guestInfo: roomGuests.adults[adultIndex],
                index: adultIndex,
                isAdult: true,
              ),
            ),
            ...List.generate(
              roomGuests.children.length,
                  (childIndex) => _buildGuestField(
                guestInfo: roomGuests.children[childIndex],
                index: childIndex,
                isAdult: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestField({
    required HotelGuestInfo guestInfo,
    required int index,
    required bool isAdult,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: _buildDropdown(
                  controller: guestInfo.titleController,
                  hint: 'Title',
                  items: isAdult ? ['Mr.', 'Mrs.', 'Ms.'] : ['Mstr.', 'Miss.'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  isAdult ? "Adult ${index + 1}" : "Child ${index + 1}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: guestInfo.firstNameController,
                  hint: 'First Name',
                  prefixIcon: Icons.person_outline,
                  iconColor: const Color(0xFFFFAB00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: guestInfo.lastNameController,
                  hint: 'Last Name',
                  prefixIcon: Icons.person_outline,
                  iconColor: const Color(0xFFFFAB00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookerInfoCard() {

    return Card(
      elevation: 4,
      color: TColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booker Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFAB00),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDropdown(
                    controller: bookingController.titleController,
                    hint: 'Title',
                    items: ['Mr.', 'Mrs.', 'Ms.'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: bookingController.firstNameController,
                    hint: 'First Name',
                    prefixIcon: Icons.person_outline,
                    iconColor: const Color(0xFFFFAB00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: bookingController.lastNameController,
                    hint: 'Last Name',
                    prefixIcon: Icons.person_outline,
                    iconColor: const Color(0xFFFFAB00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: bookingController.emailController,
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              iconColor: const Color(0xFFFFAB00),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: bookingController.phoneController,
              hint: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              iconColor: const Color(0xFFFFAB00),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: bookingController.addressController,
                    hint: 'Address Line',
                    prefixIcon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFFFAB00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: bookingController.cityController,
                    hint: 'City',
                    prefixIcon: Icons.location_city_outlined,
                    iconColor: const Color(0xFFFFAB00),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRequestsCard() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: bookingController.specialRequestsController,
              hint: 'Enter any special requests',
              prefixIcon: Icons.note_add_outlined,
              iconColor: const Color(0xFFFFAB00),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
              children: [
                _buildCheckboxTile(
                  'Ground Floor',
                  bookingController.isGroundFloor.value,
                      (value) => bookingController.isGroundFloor.value = value!,
                ),
                _buildCheckboxTile(
                  'High Floor',
                  bookingController.isHighFloor.value,
                      (value) => bookingController.isHighFloor.value = value!,
                ),
                _buildCheckboxTile(
                  'Late Checkout',
                  bookingController.isLateCheckout.value,
                      (value) =>
                  bookingController.isLateCheckout.value = value!,
                ),
                _buildCheckboxTile(
                  'Early Checkin',
                  bookingController.isEarlyCheckin.value,
                      (value) =>
                  bookingController.isEarlyCheckin.value = value!,
                ),
                _buildCheckboxTile(
                  'Twin Bed',
                  bookingController.isTwinBed.value,
                      (value) => bookingController.isTwinBed.value = value!,
                ),
                _buildCheckboxTile(
                  'Smoking Room',
                  bookingController.isSmoking.value,
                      (value) => bookingController.isSmoking.value = value!,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Obx(() => CheckboxListTile(
      title: const Text(
        'I accept the terms and conditions',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      value: bookingController.acceptedTerms.value,
      onChanged: (value) => bookingController.acceptedTerms.value = value!,
      activeColor: const Color(0xFFFFAB00),
      controlAffinity: ListTileControlAffinity.leading,
    ));
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    required IconData prefixIcon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: iconColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required TextEditingController controller,
    required String hint,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.text.isEmpty ? null : controller.text,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        hint:
        Text(hint, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            controller.text = value;
          }
        },
      ),
    );
  }

  Widget _buildCheckboxTile(
      String title,
      bool value,
      Function(bool?) onChanged,
      ) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFFAB00),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSubmitButton() {

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          _handleSubmit();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFAB00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Complete Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // In booking_hotel.dart
  void _handleSubmit() async {
    try {
      bookingController.isLoading.value = true;

      if (!bookingController.validateAll()) {
        CustomSnackBar(
          message: "Please fill all required fields correctly",
          backgroundColor: Colors.red,
        ).show();
        return;
      }

      final bool success = await bookingController.saveHotelBookingToDB();

      if (success) {
        Get.to(() => const ThankYouScreen());
        CustomSnackBar(
          message: "Booking Confirmed Successfully!",
          backgroundColor: Colors.green,
        ).show();
        bookingController.resetForm();
      } else {
        CustomSnackBar(
          message: "Booking failed. Please try again.",
          backgroundColor: Colors.red,
        ).show();
      }
    } catch (e) {
      CustomSnackBar(
        message: "An error occurred. Please try again.",
        backgroundColor: Colors.red,
      ).show();
    } finally {
      bookingController.isLoading.value = false;
    }
  }
  Widget _buildBadge(String text) {
    final isRefundable = text.toLowerCase() == 'refundable';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRefundable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isRefundable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}