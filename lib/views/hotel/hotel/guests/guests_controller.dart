import 'package:get/get.dart';

class Room {
  RxInt adults = 1.obs;
  RxInt children = 0.obs;
  RxList<int> childrenAges = RxList<int>([]);

  Room();
}

class GuestsController extends GetxController {
  static const int maxRooms = 4; // Maximum number of rooms allowed

  RxInt roomCount = 1.obs;
  RxList<Room> rooms = RxList<Room>([Room()]);

  // Add a new room
  void incrementRooms() {
    if (roomCount.value < maxRooms) {
      roomCount.value++;
      rooms.add(Room());
    }
  }

  // Remove a room
  void decrementRooms() {
    if (roomCount.value > 1) {
      roomCount.value--;
      rooms.removeLast();
    }
  }

  // Increment adults in a specific room
  void incrementAdults(int roomIndex) {
    if (rooms[roomIndex].adults.value < 4) {
      rooms[roomIndex].adults.value++;
    }
  }

  // Decrement adults in a specific room
  void decrementAdults(int roomIndex) {
    if (rooms[roomIndex].adults.value > 1) {
      rooms[roomIndex].adults.value--;
    }
  }

  // Increment children in a specific room
  void incrementChildren(int roomIndex) {
    if (rooms[roomIndex].children.value < 4) {
      rooms[roomIndex].children.value++;
      rooms[roomIndex].childrenAges.add(0); // Add default age 0 for new child
    }
  }

  // Decrement children in a specific room
  void decrementChildren(int roomIndex) {
    if (rooms[roomIndex].children.value > 0) {
      rooms[roomIndex].children.value--;
      rooms[roomIndex].childrenAges.removeLast(); // Remove the last child's age
    }
  }

  // Update child's age
  void updateChildAge(int roomIndex, int childIndex, int age) {
    if (roomIndex < rooms.length &&
        childIndex < rooms[roomIndex].childrenAges.length) {
      rooms[roomIndex].childrenAges[childIndex] = age;
    }
  }

  // Get total count of adults across all rooms
  int get totalAdults => rooms.fold(0, (sum, room) => sum + room.adults.value);

  // Get total count of children across all rooms
  int get totalChildren => rooms.fold(0, (sum, room) => sum + room.children.value);
}