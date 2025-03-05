import 'package:flight_bocking/views/flight/form/travelers/traveler_controller.dart';
import 'package:flight_bocking/views/flight/search_flights/booking_flight/booking_flight_controller.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/filter_modal.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/widgets/flight_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../services/api_service_flight.dart';
import '../../../../widgets/colors.dart';

class BookingForm extends StatefulWidget {
  final Flight flight;
  const BookingForm({super.key, required this.flight});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final BookingFlightController bookingController =
  Get.put(BookingFlightController());
  final TravelersController travelersController =
  Get.put(TravelersController());
  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background2,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: TColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFlightDetails(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTravelersForm(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildBookerDetails(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildTermsAndConditions(),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTermsAndConditions() {
    return Card(
      color: TColors.background,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CheckboxListTile(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'I accept the ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: 'terms and conditions',
                style: TextStyle(
                  fontSize: 14,
                  color: TColors.primary,
                  decoration: TextDecoration.underline,
                ),
                // You can add onTap handler here if you want to show T&C
              ),
            ],
          ),
        ),
        value: termsAccepted,
        onChanged: (value) {
          setState(() {
            termsAccepted = value ?? false;
          });
        },
        activeColor: TColors.primary,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildFlightDetails() {
    return FlightCard(
      flight: widget.flight, // Pass the selected flight here
      showReturnFlight: false, // Set to true if you want to show return flight
    );
  }

  Widget _buildTravelersForm() {
    return Obx(() {
      final adults = List.generate(
        travelersController.adultCount.value,
            (index) => _buildTravelerSection(
          title: 'Adult ${index + 1}',
          isInfant: false,
          type: 'adult',
        ),
      );

      final children = List.generate(
        travelersController.childrenCount.value,
            (index) => _buildTravelerSection(
          title: 'Child ${index + 1}',
          isInfant: false,
          type: 'child',
        ),
      );

      final infants = List.generate(
        travelersController.infantCount.value,
            (index) => _buildTravelerSection(
          title: 'Infant ${index + 1}',
          isInfant: true,
          type: 'infant',
        ),
      );

      return Column(
        children: [
          ...adults,
          ...children,
          ...infants,
        ],
      );
    });
  }

  Widget _buildTravelerSection({
    required String title,
    required bool isInfant,
    required String type,
  }) {
    return Card(
      color: TColors.background,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: TColors.primary.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTravelerIcon(type),
                  color: TColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Form Fields Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == 'adult') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Gender',
                          items: ['Male', 'Female'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Title',
                          items: ['Mr.', 'Mrs.', 'Ms.', 'Dr.'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Given Name',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Surname',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          hint: 'Date of Birth',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Phone',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Nationality',
                          prefixIcon: Icons.flag_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Passport Number',
                          prefixIcon: Icons.document_scanner_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Passport Expiry',
                        ),
                      ),
                    ],
                  ),
                ],
                if (type == 'child') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Title',
                          items: ['Mstr.', 'Miss'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Given Name',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Surname',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Date of Birth',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Nationality',
                          prefixIcon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Passport Number',
                          prefixIcon: Icons.document_scanner_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          hint: 'Passport Expiry',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Gender',
                          items: ['Male', 'Female'],
                        ),
                      ),
                    ],
                  ),
                ],
                if (type == 'infant') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Title',
                          items: ['Inf.'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Given Name',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Surname',
                          prefixIcon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Date of Birth',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          hint: 'Nationality',
                          prefixIcon: Icons.flag_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Passport Number',
                          prefixIcon: Icons.document_scanner_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          hint: 'Passport Expiry',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Gender',
                          items: ['Male', 'Female'],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.calendar_today, color: TColors.primary),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        readOnly: true,
        onTap: () async {
          // Handle the selected date
        },
      ),
    );
  }

// Helper method to get appropriate icons for different traveler types
  IconData _getTravelerIcon(String type) {
    switch (type) {
      case 'adult':
        return Icons.person;
      case 'child':
        return Icons.child_care;
      case 'infant':
        return Icons.baby_changing_station;
      default:
        return Icons.person;
    }
  }


  Widget _buildBookerDetails() {
    return Card(
      color: TColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booker Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'First Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Last Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Address',
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'City',
              prefixIcon: Icons.location_city_outlined,
            ),
          ],
        ),
      ),
    );
  }

  // Rest of the widget code remains the same...

  Widget _buildTextField({
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: TColors.primary),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        hint: Text(hint),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Amount'),
              Text(
                'PKR ${widget.flight.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Get the booker's email and phone from the form
                final bookerEmail = bookingController.emailController.text;
                final bookerPhone = bookingController.phoneController.text;

                // Call the PNR request function
                final apiService = ApiServiceFlight();
                await apiService.createPNRRequest(
                  flight: widget.flight,
                  adults: bookingController.adults,
                  children: bookingController.children,
                  infants: bookingController.infants,
                  bookerEmail: bookerEmail,
                  bookerPhone: bookerPhone,
                );

                // Optionally, you can navigate to a confirmation screen or show a success message
                Get.snackbar(
                  'Success',
                  'PNR request created successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Create Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
