import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../booking_card/forms/hotel/guests/guests_controller.dart';

class HotelGuestInfo {
  final TextEditingController titleController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  HotelGuestInfo()
      : titleController = TextEditingController(),
        firstNameController = TextEditingController(),
        lastNameController = TextEditingController();

  void dispose() {
    titleController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  bool isValid() {
    return titleController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
  }
}

class RoomGuests {
  final List<HotelGuestInfo> adults;
  final List<HotelGuestInfo> children;

  RoomGuests({
    required this.adults,
    required this.children,
  });

  void dispose() {
    for (var adult in adults) {
      adult.dispose();
    }
    for (var child in children) {
      child.dispose();
    }
  }
}

class BookingController extends GetxController {
  // Room guest information
  final RxList<RoomGuests> roomGuests = <RoomGuests>[].obs;

  // Booker Information
  final titleController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final specialRequestsController = TextEditingController();

  // Special Requests Checkboxes
  final isGroundFloor = false.obs;
  final isHighFloor = false.obs;
  final isLateCheckout = false.obs;
  final isEarlyCheckin = false.obs;
  final isTwinBed = false.obs;
  final isSmoking = false.obs;

  // Terms and Conditions
  final acceptedTerms = false.obs;

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with existing GuestsController data
    initializeRoomGuests();
  }

  void initializeRoomGuests() {
    final guestsController = Get.put(GuestsController());

    roomGuests.clear();
    for (var room in guestsController.rooms) {
      final adults = List.generate(
        room.adults.value,
            (_) => HotelGuestInfo(),
      );

      final children = List.generate(
        room.children.value,
            (_) => HotelGuestInfo(),
      );

      roomGuests.add(RoomGuests(adults: adults, children: children));
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
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        isEmailValid(emailController.text) &&
        phoneController.text.isNotEmpty &&
        isPhoneValid(phoneController.text) &&
        addressController.text.isNotEmpty &&
        cityController.text.isNotEmpty;
  }

  bool validateAllGuestInfo() {
    for (var room in roomGuests) {
      for (var adult in room.adults) {
        if (!adult.isValid()) return false;
      }
      for (var child in room.children) {
        if (!child.isValid()) return false;
      }
    }
    return true;
  }

  bool validateAll() {
    return validateBookerInfo() &&
        validateAllGuestInfo() &&
        acceptedTerms.value;
  }

  // Submit booking
  Future<bool> submitBooking() async {
    if (!validateAll()) {
      return false;
    }

    try {
      isLoading.value = true;

      // Create booking data model
      final bookingData = {
        'booker': {
          'title': titleController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'city': cityController.text,
        },
        'rooms': roomGuests.asMap().map((index, room) {
          return MapEntry(
            'room_${index + 1}',
            {
              'adults': room.adults.map((adult) => {
                'title': adult.titleController.text,
                'firstName': adult.firstNameController.text,
                'lastName': adult.lastNameController.text,
              }).toList(),
              'children': room.children.map((child) => {
                'title': child.titleController.text,
                'firstName': child.firstNameController.text,
                'lastName': child.lastNameController.text,
              }).toList(),
            },
          );
        }),
        'specialRequests': {
          'text': specialRequestsController.text,
          'groundFloor': isGroundFloor.value,
          'highFloor': isHighFloor.value,
          'lateCheckout': isLateCheckout.value,
          'earlyCheckin': isEarlyCheckin.value,
          'twinBed': isTwinBed.value,
          'smoking': isSmoking.value,
        },
      };

      // Here you would typically send bookingData to your backend
      // await bookingService.createBooking(bookingData);

      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    // Reset booker information
    titleController.clear();
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    specialRequestsController.clear();

    // Reset special requests
    isGroundFloor.value = false;
    isHighFloor.value = false;
    isLateCheckout.value = false;
    isEarlyCheckin.value = false;
    isTwinBed.value = false;
    isSmoking.value = false;

    // Reset terms
    acceptedTerms.value = false;

    // Reset room guests
    initializeRoomGuests();
  }

  @override
  void onClose() {
    // Dispose booker information controllers
    titleController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    specialRequestsController.dispose();

    // Dispose room guest controllers
    for (var room in roomGuests) {
      room.dispose();
    }

    super.onClose();
  }
}