
import 'package:get/get.dart';

class SelectRoomController extends GetxController {
  // Store prebook API response
  final Rx<Map<String, dynamic>> prebookResponse = Rx<Map<String, dynamic>>({});

  // Observable lists to store policy details for each room
  final RxList<List<Map<String, dynamic>>> roomsPolicyDetails = RxList<List<Map<String, dynamic>>>([]);

  // Observable maps to store room details
  final RxMap<int, String> roomNames = RxMap<int, String>({});
  final RxMap<int, String> roomMeals = RxMap<int, String>({});
  final RxMap<int, String> roomRateTypes = RxMap<int, String>({}); // Added for rate types

  // Method to store prebook response data
  void storePrebookResponse(Map<String, dynamic> response) {
    prebookResponse.value = response;

    // Extract and store room details
    if (response['hotel']?['rooms']?['room'] != null) {
      final rooms = response['hotel']['rooms']['room'] as List;

      roomsPolicyDetails.clear();
      roomNames.clear();
      roomMeals.clear();
      roomRateTypes.clear(); // Clear rate types

      for (var i = 0; i < rooms.length; i++) {
        final room = rooms[i];

        // Store room name, meal and rate type
        roomNames[i] = room['roomName'] ?? '';
        roomMeals[i] = room['meal'] ?? '';
        roomRateTypes[i] = room['rateType'] ?? ''; // Store rate type

        // Extract policy details
        if (room['policies']?['policy'] != null) {
          List<Map<String, dynamic>> policyDetails = [];

          for (var policy in room['policies']['policy']) {
            if (policy['condition'] != null) {
              for (var condition in policy['condition']) {
                policyDetails.add({
                  "from_date": condition['fromDate'] ?? '',
                  "to_date": condition['toDate'] ?? '',
                  "timezone": condition['timezone'] ?? '',
                  "from_time": condition['fromTime'] ?? '',
                  "to_time": condition['toTime'] ?? '',
                  "percentage": condition['percentage'] ?? '',
                  "nights": condition['nights'] ?? '',
                  "fixed": condition['fixed'] ?? '',
                  "applicableOn": condition['applicableOn'] ?? ''
                });
              }
            }
          }

          if (roomsPolicyDetails.length <= i) {
            roomsPolicyDetails.add(policyDetails);
          } else {
            roomsPolicyDetails[i] = policyDetails;
          }
        }
      }
    }
  }

  // Method to get policy details for a specific room
  List<Map<String, dynamic>> getPolicyDetailsForRoom(int roomIndex) {
    if (roomIndex < roomsPolicyDetails.length) {
      return roomsPolicyDetails[roomIndex];
    }
    return [];
  }

  // Method to get room name for a specific room
  String getRoomName(int roomIndex) {
    return roomNames[roomIndex] ?? '';
  }

  // Method to get meal plan for a specific room
  String getRoomMeal(int roomIndex) {
    return roomMeals[roomIndex] ?? '';
  }

  // Method to get rate type for a specific room
  String getRateType(int roomIndex) {
    return roomRateTypes[roomIndex] ?? '';
  }

  // Method to clear all stored data
  void clearData() {
    prebookResponse.value = {};
    roomsPolicyDetails.clear();
    roomNames.clear();
    roomMeals.clear();
    roomRateTypes.clear();
  }
}