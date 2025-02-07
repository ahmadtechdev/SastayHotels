
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

  Future<bool> saveHotelBookingToDB() async  {
    final selectRoomController = Get.put(SelectRoomController());
    List<Map<String, dynamic>> roomsList = [];
    final dateFormat = DateFormat('yyyy-MM-dd');

    try {

      // Calculate total buying price from selected rooms
      double totalBuyingPrice = 0;
      for (var roomData in searchHotelController.selectedRoomsData) {
        if (roomData['price'] != null) {
          // Get price per night
          double pricePerNight = double.tryParse(roomData['price']['net'].toString()) ?? 0;
          // Multiply by number of nights
          totalBuyingPrice += pricePerNight * hotelDateController.nights.value;
        }
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

        // Get the policy details for the room
        final policyDetails = selectRoomController.getPolicyDetailsForRoom(i);
        String pEndDate = "";
        String pEndTime = "";

        if (policyDetails.isNotEmpty) {
          final firstPolicy = policyDetails.first;
          pEndDate = firstPolicy['from_date']?.split('T')?.first ?? "";
          pEndTime = firstPolicy['from_time'] ?? "";
        }

        // Create room object with null safety
        Map<String, dynamic> roomObject = {
          "p_nature": selectRoomController.getRateType(i),
          "p_type": "CAN",
          "p_end_date": pEndDate,
          "p_end_time": pEndTime,
          "room_name": selectRoomController.getRoomName(i),
          "room_bordbase": selectRoomController.getRoomMeal(i),
          "policy_details": policyDetails,
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
        "buying_price": double.parse(totalBuyingPrice.toStringAsFixed(2)),
        "om_regid": searchHotelController.destinationCode.value,
        "om_hname": searchHotelController.hotelName.value,
        "om_destination": searchHotelController.hotelCity.value,
        "om_trooms": guestsController.roomCount.value,
        "om_chindate": dateFormat.format(hotelDateController.checkInDate.value),
        "om_choutdate": dateFormat.format(hotelDateController.checkOutDate.value),
        "om_spreq": specialRequests.isEmpty ? "" : specialRequests.join(', '),
        "om_smoking": "",
        "om_status": "0",
        "payment_status": "Pending",
        "om_suppliername": "Arabian",
        "Rooms": roomsList
      };

      isLoading.value = true;
      // Send the booking request
      final bool success = await apiService.bookHotel(requestBody);

      isLoading.value = false;
      return success;
    } catch (e) {
      rethrow;
    }
  }

// Helper method to build rate key
  String _buildRateKey() {
    try {
      if (searchHotelController.selectedRoomsData.isEmpty) return "";

      List<String> rateKeys = searchHotelController.selectedRoomsData
          .map((room) => room['rateKey']?.toString() ?? "")
          .where((key) => key.isNotEmpty)
          .toList();

      return rateKeys.isEmpty ? "" : "start${rateKeys.join('za,in')}";
    } catch (e) {
      print('Error building rate key: $e');
      return "";
    }
  }


// Rest of your code remains the same...
}