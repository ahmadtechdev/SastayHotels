import 'package:get/get.dart';

class GuestsController extends GetxController {
  var roomCount = 1.obs; // Default to 1 room
  var adultsPerRoom = <int>[1].obs; // Default to 1 adult per room
  var childrenPerRoom = <int>[0].obs; // Default to 0 children per room

  // Increment rooms
  void incrementRooms() {
    if (roomCount.value < 10) {
      roomCount.value++;
      adultsPerRoom.add(1); // Default 1 adult for the new room
      childrenPerRoom.add(0); // Default 0 children for the new room
    }
  }

  // Decrement rooms
  void decrementRooms() {
    if (roomCount.value > 1) {
      roomCount.value--;
      adultsPerRoom.removeLast();
      childrenPerRoom.removeLast();
    }
  }

  // Increment adults in a specific room
  void incrementAdults(int roomNumber) {
    if (adultsPerRoom[roomNumber - 1] < 4) {
      adultsPerRoom[roomNumber - 1]++;
      adultsPerRoom.refresh(); // Notify UI of the change
    }
  }

  // Decrement adults in a specific room
  void decrementAdults(int roomNumber) {
    if (adultsPerRoom[roomNumber - 1] > 1) {
      adultsPerRoom[roomNumber - 1]--;
      adultsPerRoom.refresh(); // Notify UI of the change
    }
  }

  // Increment children in a specific room
  void incrementChildren(int roomNumber) {
    if (childrenPerRoom[roomNumber - 1] < 4) {
      childrenPerRoom[roomNumber - 1]++;
      childrenPerRoom.refresh(); // Notify UI of the change
    }
  }

  // Decrement children in a specific room
  void decrementChildren(int roomNumber) {
    if (childrenPerRoom[roomNumber - 1] > 0) {
      childrenPerRoom[roomNumber - 1]--;
      childrenPerRoom.refresh(); // Notify UI of the change
    }
  }
}
