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
  @override
  void dispose() {
    bookingController.dispose();
    travelersController.dispose();
    super.dispose();
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
          type: 'adult', index: index,
        ),
      );

      final children = List.generate(
        travelersController.childrenCount.value,
            (index) => _buildTravelerSection(
          title: 'Child ${index + 1}',
          isInfant: false,
          type: 'child', index: index,
        ),
      );

      final infants = List.generate(
        travelersController.infantCount.value,
            (index) => _buildTravelerSection(
          title: 'Infant ${index + 1}',
          isInfant: true,
          type: 'infant',
                index: index
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
    required int index,
  }) {
    // Get the corresponding TravelerInfo object based on the type and index
    TravelerInfo travelerInfo;
    if (type == 'adult') {
      travelerInfo = bookingController.adults[index];
    } else if (type == 'child') {
      travelerInfo = bookingController.children[index];
    } else {
      travelerInfo = bookingController.infants[index];
    }

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
                          controller: travelerInfo.genderController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Title',
                          items: ['Mr', 'Mrs', 'Ms'],
                          controller: travelerInfo.titleController,
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
                          controller: travelerInfo.firstNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Surname',
                          prefixIcon: Icons.person_outline,
                          controller: travelerInfo.lastNameController,
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
                          controller: travelerInfo.dateOfBirthController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Phone',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          controller: travelerInfo.phoneController,
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
                          controller: travelerInfo.emailController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Nationality',
                          prefixIcon: Icons.flag_outlined,
                          controller: travelerInfo.nationalityController,
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
                          controller: travelerInfo.passportController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Passport Expiry',
                          controller: travelerInfo.passportExpiryController,
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
                          items: ['Mstr', 'Miss'],
                          controller: travelerInfo.titleController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Given Name',
                          prefixIcon: Icons.person_outline,
                          controller: travelerInfo.firstNameController,
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
                          controller: travelerInfo.lastNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Date of Birth',
                          controller: travelerInfo.dateOfBirthController,
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
                          controller: travelerInfo.nationalityController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Passport Number',
                          prefixIcon: Icons.document_scanner_outlined,
                          controller: travelerInfo.passportController,
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
                          controller: travelerInfo.passportExpiryController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Gender',
                          items: ['Male', 'Female'],
                          controller: travelerInfo.genderController,
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
                          items: ['Inf'],
                          controller: travelerInfo.titleController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Given Name',
                          prefixIcon: Icons.person_outline,
                          controller: travelerInfo.firstNameController,
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
                          controller: travelerInfo.lastNameController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          hint: 'Date of Birth',
                          controller: travelerInfo.dateOfBirthController,
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
                          controller: travelerInfo.nationalityController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          hint: 'Passport Number',
                          prefixIcon: Icons.document_scanner_outlined,
                          controller: travelerInfo.passportController,
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
                          controller: travelerInfo.passportExpiryController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          hint: 'Gender',
                          items: ['Male', 'Female'],
                          controller: travelerInfo.genderController,
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

  Widget _buildDateField({
    required String hint,
    required TextEditingController controller, // Pass the controller
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller, // Bind the controller
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.calendar_today, color: TColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        readOnly: true,
        onTap: () async {
          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Update the controller
          }
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
              controller: bookingController.firstNameController, // Bind to controller
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Last Name',
              prefixIcon: Icons.person_outline,
              controller: bookingController.lastNameController, // Bind to controller
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: bookingController.emailController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Phone',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              controller: bookingController.phoneController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'Address',
              prefixIcon: Icons.location_on_outlined,
              controller: bookingController.addressController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              hint: 'City',
              prefixIcon: Icons.location_city_outlined,
              controller: bookingController.cityController,
            ),
          ],
        ),
      ),
    );
  }

  // Rest of the widget code remains the same...

  Widget _buildDropdown({
    required String hint,
    required List<String> items,
    required TextEditingController controller,
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
        onChanged: (value) {
          controller.text = value ?? '';
        },
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: TColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
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
                // Print all booker details
                print('Booker Details:');
                print('First Name: ${bookingController.firstNameController.text}');
                print('Last Name: ${bookingController.lastNameController.text}');
                print('Email: ${bookingController.emailController.text}');
                print('Phone: ${bookingController.phoneController.text}');
                print('Address: ${bookingController.addressController.text}');
                print('City: ${bookingController.cityController.text}');

                // Print all adult details
                for (var i = 0; i < bookingController.adults.length; i++) {
                  print('Adult ${i + 1} Details:');
                  print('Title: ${bookingController.adults[i].titleController.text}');
                  print('First Name: ${bookingController.adults[i].firstNameController.text}');
                  print('Last Name: ${bookingController.adults[i].lastNameController.text}');
                  print('Date of Birth: ${bookingController.adults[i].dateOfBirthController.text}');
                  print('Phone: ${bookingController.adults[i].phoneController.text}');
                  print('Email: ${bookingController.adults[i].emailController.text}');
                  print('Nationality: ${bookingController.adults[i].nationalityController.text}');
                  print('Passport Number: ${bookingController.adults[i].passportController.text}');
                  print('Passport Expiry: ${bookingController.adults[i].passportExpiryController.text}');
                }

                // Print all child details
                for (var i = 0; i < bookingController.children.length; i++) {
                  print('Child ${i + 1} Details:');
                  print('Title: ${bookingController.children[i].titleController.text}');
                  print('First Name: ${bookingController.children[i].firstNameController.text}');
                  print('Last Name: ${bookingController.children[i].lastNameController.text}');
                  print('Date of Birth: ${bookingController.children[i].dateOfBirthController.text}');
                  print('Nationality: ${bookingController.children[i].nationalityController.text}');
                  print('Passport Number: ${bookingController.children[i].passportController.text}');
                  print('Passport Expiry: ${bookingController.children[i].passportExpiryController.text}');
                }

                // Print all infant details
                for (var i = 0; i < bookingController.infants.length; i++) {
                  print('Infant ${i + 1} Details:');
                  print('Title: ${bookingController.infants[i].titleController.text}');
                  print('First Name: ${bookingController.infants[i].firstNameController.text}');
                  print('Last Name: ${bookingController.infants[i].lastNameController.text}');
                  print('Date of Birth: ${bookingController.infants[i].dateOfBirthController.text}');
                  print('Nationality: ${bookingController.infants[i].nationalityController.text}');
                  print('Passport Number: ${bookingController.infants[i].passportController.text}');
                  print('Passport Expiry: ${bookingController.infants[i].passportExpiryController.text}');
                }

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
