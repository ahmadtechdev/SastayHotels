// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/api_service_hotel.dart';
import '../../hotel/guests/guests_controller.dart';
import '../../hotel/hotel_date_controller.dart';
import '../search_hotel_controller.dart';
import '../select_room/controller/select_room_controller.dart';

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
      Get.find<SearchHotelController>();
  HotelDateController hotelDateController = Get.find<HotelDateController>();
  GuestsController guestsController = Get.find<GuestsController>();
  SelectRoomController SelectRoomcontroller = Get.find<SelectRoomController>();
  var buying_price = ''.obs;
  var censelation_date = ''.obs;
  var booking_num = 0.obs;

  

  ApiServiceHotel apiService = ApiServiceHotel();

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
    final guestsController = Get.find<GuestsController>();

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

  void resetForm() {
    // Reset booker information
    // titleController.clear();
    // firstNameController.clear();
    // lastNameController.clear();
    // emailController.clear();
    // phoneController.clear();
    // addressController.clear();
    // cityController.clear();
    // specialRequestsController.clear();

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

  Future<bool> saveHotelBookingToDB() async {
    final selectRoomController = Get.put(SelectRoomController());
    List<Map<String, dynamic>> roomsList = [];
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {
      // Calculate total buying price from selected rooms
      for (var roomData in searchHotelController.selectedRoomsData) {
        if (roomData['price'] != null) {}
      }

      for (var i = 0; i < roomGuests.length; i++) {
        List<Map<String, dynamic>> paxDetails = [];

        // Add adults
        for (var adult in roomGuests[i].adults) {
          if (adult.titleController.text.isEmpty ||
              adult.firstNameController.text.isEmpty ||
              adult.lastNameController.text.isEmpty) {
            throw Exception('Adult details missing for room ${i + 1}');
          }

          paxDetails.add({
            "type": "Adult",
            "title": adult.titleController.text.trim(),
            "first": adult.firstNameController.text.trim(),
            "last": adult.lastNameController.text.trim(),
            "age": ""
          });
        }

        // Add children with null safety
        if (roomGuests[i].children.isNotEmpty) {
          for (var j = 0; j < roomGuests[i].children.length; j++) {
            var child = roomGuests[i].children[j];
            var childAge = guestsController.rooms[i].childrenAges.isNotEmpty &&
                    j < guestsController.rooms[i].childrenAges.length
                ? guestsController.rooms[i].childrenAges[j].toString()
                : "0";

            if (child.titleController.text.isEmpty ||
                child.firstNameController.text.isEmpty ||
                child.lastNameController.text.isEmpty) {
              throw Exception('Child details missing for room ${i + 1}');
            }

            paxDetails.add({
              "type": "Child",
              "title": child.titleController.text.trim(),
              "first": child.firstNameController.text.trim(),
              "last": child.lastNameController.text.trim(),
              "age": childAge
            });
          }
        }

        // Get the policy details for the room with reformatted dates
        final policyDetails = selectRoomController.getPolicyDetailsForRoom(i);
        List<Map<String, dynamic>> formattedPolicyDetails = [];

        for (var policy in policyDetails) {
          // Parse the ISO date string and format it to yyyy-MM-dd
          String formattedFromDate = "";
          if (policy['from_date'] != null && policy['from_date'].isNotEmpty) {
            try {
              DateTime parsedDate = DateTime.parse(policy['from_date']);
              formattedFromDate = DateFormat('yyyy-MM-dd').format(parsedDate);
            } catch (e) {
              print('Error parsing date: ${e.toString()}');
              formattedFromDate = policy['from_date'].split('T')[0];
            }
          }

          formattedPolicyDetails.add({
            "from_date": formattedFromDate,
            "amount": policy['amount'],
            "to_date": policy['to_date'] ?? ""
          });
        }

        // Create room object with formatted policy details
        Map<String, dynamic> roomObject = {
          "p_nature": selectRoomController.getRateType(i),
          "p_type": "CAN",
          "p_end_date": formattedPolicyDetails.isNotEmpty
              ? formattedPolicyDetails.first['from_date']
              : "",
          "p_end_time":
              selectRoomController.getPolicyDetailsForRoom(i).isNotEmpty
                  ? selectRoomController
                          .getPolicyDetailsForRoom(i)
                          .first['from_time'] ??
                      ""
                  : "",
          "room_name": selectRoomController.getRoomName(i),
          "room_bordbase": selectRoomController.getRoomMeal(i),
          "policy_details": formattedPolicyDetails,
          "pax_details": paxDetails
        };

        roomsList.add(roomObject);
      }

      // Prepare special requests list
      List<String> specialRequests = [];
      if (isGroundFloor.value) specialRequests.add("Ground Floor");
      if (isHighFloor.value) specialRequests.add("High Floor");
      if (isLateCheckout.value) specialRequests.add("Late checkout");
      if (isEarlyCheckin.value) specialRequests.add("Early checkin");
      if (isTwinBed.value) specialRequests.add("Twin Bed");
      if (isSmoking.value) specialRequests.add("Smoking");

      // Create request body with null safety
      final Map<String, dynamic> requestBody = {
        "bookeremail": emailController.text.trim(),
        "bookerfirst": firstNameController.text.trim(),
        "bookerlast": lastNameController.text.trim(),
        "bookertel": phoneController.text.trim(),
        "bookeraddress": addressController.text.trim(),
        "bookercompany": "",
        "bookercountry": "",
        "bookercity": cityController.text.trim(),
        "om_ordate": DateTime.now().toIso8601String().split('T')[0].toString(),
        "cancellation_buffer": "",
        "session_id": searchHotelController.sessionId.value,
        "group_code": searchHotelController.roomsdata.isNotEmpty
            ? searchHotelController.roomsdata[0]['groupCode'] ?? ""
            : "",
        "rate_key": _buildRateKey(),
        "om_hid": searchHotelController.hotelCode.value,
        "om_nights": hotelDateController.nights.value,
        "buying_price": buying_price.toString(),
        "om_hname": searchHotelController.hotelName.value,
        "om_destination": searchHotelController.hotelCity.value,
        "om_trooms": guestsController.roomCount.value,
        "om_chindate": dateFormat.format(hotelDateController.checkInDate.value),
        "om_choutdate":
            dateFormat.format(hotelDateController.checkOutDate.value),
        "om_spreq": specialRequests.isEmpty ? "" : specialRequests.join(', '),
        "om_smoking": "",
        "om_status": "0",
        "payment_status": "Pending",
        "om_suppliername": "Arabian",
        "Rooms": roomsList
      };

      isLoading.value = true;
      final bool success = await apiService.bookHotel(requestBody);
      isLoading.value = false;
      return success;
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

// Helper method to build rate key

  String _buildRateKey() {
    try {
      final selectRoomController = Get.find<SelectRoomController>();

      if (selectRoomController.rateKeys.isEmpty) return "";

      // Get all the rate keys as a list
      List<String> rateKeysList = selectRoomController.rateKeys.values.toList();
      rateKeysList = rateKeysList.where((key) => key.isNotEmpty).toList();

      return rateKeysList.isEmpty ? "" : "start${rateKeysList.join('za,in')}";
    } catch (e) {
      print('Error building rate key: $e');
      return "";
    }
  }

// Rest of your code remains the same...
}
