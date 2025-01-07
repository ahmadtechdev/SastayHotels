import 'package:flight_bocking/home_search/booking_card/forms/hotel/hotel_date_controller.dart';
import 'package:flight_bocking/home_search/search_hotels/search_hotel_controller.dart';
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
  SearchHotelController searchHotelController =
      Get.put(SearchHotelController());
  HotelDateController hotelDateController = Get.put(HotelDateController());
  GuestsController guestsController = Get.put(GuestsController());
  HotelDateController hotelDatecontroller = Get.put(HotelDateController());

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
              'adults': room.adults
                  .map((adult) => {
                        'title': adult.titleController.text,
                        'firstName': adult.firstNameController.text,
                        'lastName': adult.lastNameController.text,
                      })
                  .toList(),
              'children': room.children
                  .map((child) => {
                        'title': child.titleController.text,
                        'firstName': child.firstNameController.text,
                        'lastName': child.lastNameController.text,
                      })
                  .toList(),
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

  Future<void> saveHotelBookingToDB() async {
    List<Map<String, dynamic>> roomsList = [];

    // Get the selected rooms from the SelectRoomScreen
    final selectedRoomsData =
        Get.find<SearchHotelController>().selectedRoomsData;

    // Iterate through each selected room
    for (var i = 0; i < roomGuests.length; i++) {
      // Get the selected room data for this specific room
      var roomData = selectedRoomsData[i];

      // Prepare pax details for both adults and children
      List<Map<String, dynamic>> paxDetails = [];

      // Add adults
      for (var adult in roomGuests[i].adults) {
        paxDetails.add({
          "type": "ADT",
          "title": adult.titleController.text,
          "first": adult.firstNameController.text,
          "last": adult.lastNameController.text,
          "age": ""
        });
      }

      // Add children
      for (var j = 0; j < roomGuests[i].children.length; j++) {
        var child = roomGuests[i].children[j];
        paxDetails.add({
          "type": "CHD",
          "title": child.titleController.text,
          "first": child.firstNameController.text,
          "last": child.lastNameController.text,
          "age": guestsController.rooms[i].childrenAges[j].toString()
        });
      }

      // Create room object with the correct room name and meal for each selected room
      Map<String, dynamic> roomObject = {
        "p_nature": "",
        "p_type": "CAN",
        "p_end_date": "",
        "p_end_time": "",
        "room_name": roomData['roomName'] ?? "", // Use the selected room's name
        "room_bordbase": roomData['meal'] ?? "", // Use the selected room's meal
        "policy_details": [
          {
            "from_date": hotelDatecontroller.checkInDate.toString(),
            "to_date": hotelDatecontroller.checkOutDate.toString(),
            "timezone": "",
            "from_time": "",
            "to_time": "",
            "percentage": "",
            "nights": hotelDateController.nights.toString(),
            "fixed": "",
            "applicableOn": ""
          }
        ],
        "pax_details": paxDetails
      };

      roomsList.add(roomObject);
    }
    final Map<String, dynamic> requestBody = {
      "bookeremail": emailController.text,
      "bookerfirst": firstNameController.text,
      "bookerlast": lastNameController.text,
      "bookertel": phoneController.text,
      "bookeraddress": addressController.text,
      "bookercompany": "",
      "bookercountry": "",
      "bookercity": cityController.text,
      "om_ordate": DateTime.now().toIso8601String().split('T').first,
      "cancellation_buffer": "",
      "session_id": searchHotelController.sessionId,
      "group_code": searchHotelController.roomsdata[0]['groupCode'],
      "rate_key":
          "start+${searchHotelController.roomsdata.map((room) => room['rateKey']).join('za,in')}",
      "om_hid": searchHotelController.hotelCode,
      "om_nights": hotelDateController.nights,
      "buying_price": "",
      "om_regid": searchHotelController.destinationCode,
      "om_hname": searchHotelController.hotelName,
      "om_destination": searchHotelController.hotelCity,
      "om_trooms": guestsController.roomCount,
      "om_chindate": hotelDateController.checkInDate,
      "om_choutdate": hotelDateController.checkOutDate,
      "om_spreq": [
        if (isGroundFloor.value) "Ground Floor",
        if (isHighFloor.value) "High Floor",
        if (isLateCheckout.value) "Late checkout",
        if (isEarlyCheckin.value) "Early checkin",
        if (isTwinBed.value) "Twin Bed",
        if (isSmoking.value) "Smoking",
      ].join(', '),
      "om_smoking": "",
      "om_status": "0",
      "payment_status": "Pending",
      "om_suppliername": "Arabian",
      "Rooms": roomsList
    };
    print(requestBody['Rooms']);
    // Here you would typically send the requestBody to your API
  }

  // Rest of your code remains the same...
}
