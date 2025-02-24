import 'package:flight_bocking/views/flight/search_flights/booking_flight/booking_flight_controller.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/filter_modal.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/widgets/flight_card.dart';
import 'package:flight_bocking/views/hotel/hotel/guests/guests_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/colors.dart';

class BookingForm extends StatefulWidget {
  final Flight flight; // Add a flight parameter

  const BookingForm(
      {super.key, required this.flight}); // Require flight in constructor

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final BookingFlightController bookingController =
      Get.put(BookingFlightController());
  final GuestsController guestsController = Get.find<GuestsController>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background2,
      appBar: AppBar(
        surfaceTintColor: TColors.background,
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking',
          style: TextStyle(
              color: TColors.text, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingSteps(),
                const SizedBox(height: 24),
                _buildFlightDetails(),
                const SizedBox(height: 24),
                _buildRoomCards(),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  Widget _buildBookingSteps() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStepItem(icon: Icons.flight, label: 'Booking', isActive: true),
          _buildStepItem(icon: Icons.payment, label: 'Payment', number: 2),
          _buildStepItem(
              icon: Icons.confirmation_number, label: 'E-ticket', number: 3),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    IconData? icon,
    required String label,
    bool isActive = false,
    int? number,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? TColors.primary : TColors.background2,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? TColors.background : TColors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? TColors.primary : TColors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFlightDetails() {
    return FlightCard(
      flight: widget.flight, // Pass the selected flight here
      showReturnFlight: false, // Set to true if you want to show return flight
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: TColors.grey, // Specify the color of the border
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Details',
                    style: TextStyle(color: TColors.grey),
                  ),
                  Text(
                    'PKR 24,343',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process form
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    foregroundColor: TColors.background,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
