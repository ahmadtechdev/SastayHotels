import 'package:get/get.dart';

class SelectRoomController extends GetxController {
  var totalroomsprice = 0.0.obs;
  void updateTotalRoomsPrice(Map<int, dynamic> selectedRooms) {
    double totalPrice = 0.0;

    // Calculate total price for selected rooms
    selectedRooms.forEach((roomIndex, roomData) {
      if (roomData['rates'] != null && roomData['rates'].isNotEmpty) {
        final price = roomData['rates'][0]['price']?['net'];
        if (price is num) {
          totalPrice += price.toDouble();
        }
      }
    });

    // Update the observable total rooms price
    totalroomsprice.value = totalPrice;
  }

  // Store prebook API response
  final Rx<Map<String, dynamic>> prebookResponse = Rx<Map<String, dynamic>>({});

  // Observable lists to store policy details for each room
  final RxList<List<Map<String, dynamic>>> roomsPolicyDetails =
      RxList<List<Map<String, dynamic>>>([]);

  // Observable maps to store room details
  final RxMap<int, String> roomNames = RxMap<int, String>({});
  final RxMap<int, String> roomMeals = RxMap<int, String>({});
  final RxMap<int, String> roomRateTypes = RxMap<int, String>({});
  final RxMap<int, String> rateKeys = RxMap<int, String>({});

  // Method to store rate key for a specific room
  void storeRateKey(int roomIndex, String rateKey) {
    rateKeys[roomIndex] = rateKey;
  }

  // Method to get all stored rate keys
  List<String> getAllRateKeys() {
    return rateKeys.values.toList();
  } // Added for rate types

  void storePrebookResponse(Map<String, dynamic> response) {
    prebookResponse.value = response;

    // Extract and store room details
    if (response['hotel']?['rooms'] != null) {
      final rooms = response['hotel']['rooms'] as List;

      roomsPolicyDetails.clear();
      roomNames.clear();
      roomMeals.clear();
      roomRateTypes.clear();

      for (var i = 0; i < rooms.length; i++) {
        final room = rooms[i];

        // Store room name
        roomNames[i] = room['name'] ?? '';

        // Get the first rate entry for meal and rate type info
        if (room['rates'] != null && (room['rates'] as List).isNotEmpty) {
          final firstRate = room['rates'][0];
          roomMeals[i] = firstRate['boardName'] ?? '';
          roomRateTypes[i] = firstRate['rateType'] ?? '';

          // Extract cancellation policy details
          if (firstRate['cancellationPolicies'] != null) {
            List<Map<String, dynamic>> policyDetails = [];

            for (var policy in firstRate['cancellationPolicies']) {
              policyDetails.add({
                "from_date": policy['from'] ?? '',
                "amount": policy['amount'] ?? '',
                // Setting other fields as empty since they're not in the response
                "to_date": '',
                "timezone": '',
                "from_time": '',
                "to_time": '',
                "percentage": '',
                "nights": '',
                "fixed": '',
                "applicableOn": ''
              });
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
