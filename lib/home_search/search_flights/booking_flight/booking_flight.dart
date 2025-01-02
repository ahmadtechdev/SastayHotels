import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../widgets/colors.dart';
import '../../../widgets/date_selecter.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedTitle;
  bool _receiveUpdates = true;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
                _buildContactDetails(),
                const SizedBox(height: 24),
                _buildTravelerDetails(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Departing',
                style: TextStyle(color: TColors.black),
              ),
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.circle,
                size: 8,
              ),
              SizedBox(
                width: 8,
              ),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: TColors.grey,
              ),
              SizedBox(
                width: 8,
              ),
              Text('07 Dec, 2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: TColors.grey,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.flight_takeoff,
                      color: TColors.primary.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  const Text('KHI - ISB', style: TextStyle(fontSize: 16)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: TColors.primary.withOpacity(0.3)),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          "Mobile Number",
          style: TextStyle(
              color: TColors.text, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        IntlPhoneField(
          controller: _phoneController,
          showDropdownIcon: false,
          decoration: InputDecoration(
            fillColor: TColors.background,
            filled: true,
            hintText: 'Enter Your Mobile Number',
            hintStyle: const TextStyle(fontSize: 14, color: TColors.placeholder),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          initialCountryCode: 'PK', // Default country
          onChanged: (phone) {
            print(phone.completeNumber); // Full phone number with country code
          },
          onCountryChanged: (country) {
            print('Country selected: ${country.name} (+${country.dialCode})');
          },
          validator: (value) {
            if (value == null || value.number.isEmpty) {
              return 'Please enter mobile number';
            }
            return null;
          },
        ),

        const Text(
          "e.g. +92 3027253781",
          style: TextStyle(color: TColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Text(
              "Email",
              style: TextStyle(
                  color: TColors.text, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8,),
            Icon(Icons.info_outline, size: 14, color: TColors.grey,),

            SizedBox(width: 4,),
            Text(
              "(your ticket will be emailed here)",
              style: TextStyle(color: TColors.grey, fontSize: 12),
            ),
          ],
        ),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: const TextStyle(fontSize: 14, color: TColors.placeholder),
            fillColor: TColors.background,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter email';
            }
            return null;
          },
        ),
        const Text(
          "e.g. name@outlook.com",
          style: TextStyle(color: TColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Checkbox(
              value: _receiveUpdates,
              onChanged: (value) {
                setState(() {
                  _receiveUpdates = value ?? true;
                });
              },
              activeColor: TColors.primary,
            ),
            const Expanded(
              child: Text(
                'I agree to receive travel related information and deals.',
                style: TextStyle(fontSize: 12, color: TColors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTravelerDetails() {

    DateTime selectedDate = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Traveler details for Adult 1',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            fillColor: TColors.background,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          hint: const Text("Select your traveler"),
          items: [
            // Add a new traveler
            const DropdownMenuItem<String>(
              enabled: false,
              child: Text(
                "New Traveler",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: "add_new",
              child: GestureDetector(
                onTap: () {
                  // Handle the "Add a new traveler" action
                  print("Add a new traveler clicked");
                },
                child: const Text(
                  "+ Add a new traveler",
                  style: TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Divider section
            const DropdownMenuItem<String>(
              enabled: false,
              child: Text(
                "Select from my account",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Traveler options
            const DropdownMenuItem<String>(
              value: "ahmad_raza_ali",
              child: Text("Ahmad Raza Ali"),
            ),
            const DropdownMenuItem<String>(
              value: "john_doe",
              child: Text("John Doe"),
            ),
          ],
          onChanged: (value) {
            if (value != null && value != "add_new") {
              print("Selected: $value");
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a traveler';
            }
            return null;
          },
        ),


        const SizedBox(height: 16),
        const Text(
          "Title",
          style: TextStyle(
              color: TColors.text, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.only(left: 8, right: 20),
          decoration: BoxDecoration(
            color: TColors.background,
            border: Border.all(color: TColors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'Mr',
                    groupValue: _selectedTitle,
                    onChanged: (value) {
                      setState(() {
                        _selectedTitle = value!;
                      });
                    },
                    activeColor: TColors.primary,
                  ),
                  const Text('Mr'),
                ],
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    const VerticalDivider(
                      color: TColors.grey,
                      thickness: 1,
                    ),
                    Radio<String>(
                      value: 'Mrs',
                      groupValue: _selectedTitle,
                      onChanged: (value) {
                        setState(() {
                          _selectedTitle = value!;
                        });
                      },
                      activeColor: TColors.primary,
                    ),
                    const Text('Mrs'),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    const VerticalDivider(
                      color: TColors.grey,
                      thickness: 1,
                    ),
                    Radio<String>(
                      value: 'Ms',
                      groupValue: _selectedTitle,
                      onChanged: (value) {
                        setState(() {
                          _selectedTitle = value!;
                        });
                      },
                      activeColor: TColors.primary,
                    ),
                    const Text('Ms'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "First Name & Middle Name (if any)",
          style: TextStyle(
              color: TColors.text, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          decoration: InputDecoration(
            fillColor: TColors.background,
            filled: true,
            suffixIcon: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                          child: Image.asset(
                            'assets/img/1.png', // Your asset image path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.info_outline),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter first name';
            }
            return null;
          },
        ),

        const Text(
          "Enter name as per CNIC to avoid boarding issues",
          style: TextStyle(color: TColors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        const Text(
          "Last Name",
          style: TextStyle(
              color: TColors.text, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          decoration: InputDecoration(
            hintStyle: const TextStyle(
                color: TColors.placeholder,
                fontSize: 12,
                fontWeight: FontWeight.w500),
            fillColor: TColors.background,
            filled: true,
            suffixIcon: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
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
                          child: Image.asset(
                            'assets/img/2.png', // Your asset image path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: const Icon(Icons.info_outline),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter last name';
            }
            return null;
          },
        ),
        const Text(
          "Enter name as per CNIC to avoid boarding issues",
          style: TextStyle(color: TColors.grey, fontSize: 12),
        ),

        const SizedBox(height: 16),
        DateSelector(fontSize: 16, initialDate: selectedDate, onDateChanged: (DateTime value) {  },)
      ],
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
}
