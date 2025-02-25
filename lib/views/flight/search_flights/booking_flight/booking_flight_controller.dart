import 'package:flight_bocking/views/flight/form/travelers/traveler_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TravelerInfo {
  final TextEditingController titleController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController passportController;
  final TextEditingController nationalityController;
  final TextEditingController dateOfBirthController;
  final bool isInfant;

  TravelerInfo({required this.isInfant})
      : titleController = TextEditingController(),
        firstNameController = TextEditingController(),
        lastNameController = TextEditingController(),
        passportController = TextEditingController(),
        nationalityController = TextEditingController(),
        dateOfBirthController = TextEditingController();

  void dispose() {
    titleController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passportController.dispose();
    nationalityController.dispose();
    dateOfBirthController.dispose();
  }

  bool isValid() {
    if (isInfant) {
      return titleController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          dateOfBirthController.text.isNotEmpty;
    } else {
      return titleController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          passportController.text.isNotEmpty &&
          nationalityController.text.isNotEmpty;
    }
  }

  Map<String, dynamic> toJson() {
    if (isInfant) {
      return {
        'title': titleController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'dateOfBirth': dateOfBirthController.text,
      };
    } else {
      return {
        'title': titleController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'passportNumber': passportController.text,
        'nationality': nationalityController.text,
      };
    }
  }
}

class BookingFlightController extends GetxController {
  final TravelersController travelersController =
  Get.put(TravelersController());

  // Travelers information
  final RxList<TravelerInfo> adults = <TravelerInfo>[].obs;
  final RxList<TravelerInfo> children = <TravelerInfo>[].obs;
  final RxList<TravelerInfo> infants = <TravelerInfo>[].obs;

  // Booker Information
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  // Pricing information
  final totalAmount = 0.0.obs;
  final currencyCode = 'PKR'.obs;

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeTravelers();
    // Listen to changes in traveler counts
    ever(travelersController.adultCount, (_) => updateAdults());
    ever(travelersController.childrenCount, (_) => updateChildren());
    ever(travelersController.infantCount, (_) => updateInfants());
  }

  void initializeTravelers() {
    updateAdults();
    updateChildren();
    updateInfants();
  }

  void updateAdults() {
    final currentCount = adults.length;
    final newCount = travelersController.adultCount.value;

    if (newCount > currentCount) {
      // Add new adult travelers
      for (var i = currentCount; i < newCount; i++) {
        adults.add(TravelerInfo(isInfant: false));
      }
    } else if (newCount < currentCount) {
      // Remove excess adult travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        adults[i].dispose();
        adults.removeAt(i);
      }
    }
  }

  void updateChildren() {
    final currentCount = children.length;
    final newCount = travelersController.childrenCount.value;

    if (newCount > currentCount) {
      // Add new child travelers
      for (var i = currentCount; i < newCount; i++) {
        children.add(TravelerInfo(isInfant: false));
      }
    } else if (newCount < currentCount) {
      // Remove excess child travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        children[i].dispose();
        children.removeAt(i);
      }
    }
  }

  void updateInfants() {
    final currentCount = infants.length;
    final newCount = travelersController.infantCount.value;

    if (newCount > currentCount) {
      // Add new infant travelers
      for (var i = currentCount; i < newCount; i++) {
        infants.add(TravelerInfo(isInfant: true));
      }
    } else if (newCount < currentCount) {
      // Remove excess infant travelers
      for (var i = currentCount - 1; i >= newCount; i--) {
        infants[i].dispose();
        infants.removeAt(i);
      }
    }
  }

  // Validation methods
  bool isEmailValid(String email) {
    return GetUtils.isEmail(email);
  }

  bool isPhoneValid(String phone) {
    return GetUtils.isPhoneNumber(phone);
  }

  bool validateBookerInfo() {
    return emailController.text.isNotEmpty &&
        isEmailValid(emailController.text) &&
        phoneController.text.isNotEmpty &&
        isPhoneValid(phoneController.text) &&
        addressController.text.isNotEmpty &&
        cityController.text.isNotEmpty;
  }

  bool validateAllTravelersInfo() {
    bool adultsValid = adults.every((adult) => adult.isValid());
    bool childrenValid = children.every((child) => child.isValid());
    bool infantsValid = infants.every((infant) => infant.isValid());

    return adultsValid && childrenValid && infantsValid;
  }

  bool validateAll() {
    return validateBookerInfo() && validateAllTravelersInfo();
  }

  // Create booking payload
  Map<String, dynamic> createBookingPayload() {
    return {
      'booker': {
        'email': emailController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'city': cityController.text,
      },
      'travelers': {
        'adults': adults.map((adult) => adult.toJson()).toList(),
        'children': children.map((child) => child.toJson()).toList(),
        'infants': infants.map((infant) => infant.toJson()).toList(),
      },
      'travelClass': travelersController.travelClass.value,
      'totalAmount': totalAmount.value,
      'currencyCode': currencyCode.value,
    };
  }

  Future<void> submitBooking() async {
    if (!validateAll()) {
      Get.snackbar(
        'Validation Error',
        'Please fill in all required fields correctly',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      // TODO: Implement API call with createBookingPayload()
      await Future.delayed(const Duration(seconds: 2)); // Simulated API call
      Get.snackbar(
        'Success',
        'Booking submitted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate to confirmation or payment screen
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit booking',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    // Reset booker information
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();

    // Reset all travelers
    adults.clear();
    children.clear();
    infants.clear();

    // Reinitialize travelers based on current counts
    initializeTravelers();
  }

  @override
  void onClose() {
    // Dispose booker information controllers
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();

    // Dispose all traveler controllers
    for (var adult in adults) {
      adult.dispose();
    }
    for (var child in children) {
      child.dispose();
    }
    for (var infant in infants) {
      infant.dispose();
    }

    super.onClose();
  }
}
