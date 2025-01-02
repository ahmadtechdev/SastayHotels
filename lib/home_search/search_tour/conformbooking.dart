import 'package:flight_bocking/home_search/search_tour/tourcontroler.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:flight_bocking/widgets/snackbar.dart';
import 'package:flight_bocking/widgets/thankuscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConformBooking extends StatelessWidget {
  final Tourcontroler tourcontroler = Get.put(Tourcontroler());

  ConformBooking({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Booking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: TColors.primary.withOpacity(0.1),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Image.asset(height: 250, 'assets/img/Cbooking.png')),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              // Form Fields
              _buildTextField(
                controller: tourcontroler.firstNameController,
                label: "First Name",
                hintText: "Enter your first name",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tourcontroler.lastNameController,
                label: "Last Name",
                hintText: "Enter your last name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tourcontroler.emailController,
                label: "Email",
                hintText: "Enter your email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tourcontroler.phoneController,
                label: "Phone Number",
                hintText: "Enter your phone number",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tourcontroler.addressController,
                label: "Address",
                hintText: "Enter your address",
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: tourcontroler.cityController,
                label: "City",
                hintText: "Enter your city",
                icon: Icons.location_city,
              ),
              const SizedBox(height: 20),
              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(const ThankYouScreen());

                      // Validate input and handle submission
                      if (_validateFields()) {
                        CustomSnackBar(
                                message: "Booking Confirmed!",
                                backgroundColor: Colors.green)
                            .show();
                      } else {
                        CustomSnackBar(
                                message: "Please fill all required fields!",
                                backgroundColor: TColors.third)
                            .show();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Proceed to Complete Booking",
                      style: TextStyle(fontSize: screenSize.width * 0.045),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build text fields with icons
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: TColors.primary),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: TColors.black)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: TColors.black)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
    );
  }

  // Validate form fields
  bool _validateFields() {
    return tourcontroler.firstNameController.text.isNotEmpty &&
        tourcontroler.lastNameController.text.isNotEmpty &&
        tourcontroler.emailController.text.isNotEmpty &&
        tourcontroler.phoneController.text.isNotEmpty;
  }
}
