import 'package:flight_bocking/services/api_service_hotel.dart';
import 'package:flight_bocking/views/hotel/search_hotels/booking_hotel/booking_controller.dart';
import 'package:flight_bocking/views/hotel/search_hotels/booking_hotel/booking_hotel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';

import '../../hotel/guests/guests_controller.dart';
import '../../hotel/hotel_date_controller.dart';
import '../search_hotel_controller.dart';
import 'controller/select_room_controller.dart';
import 'widgets/room_card.dart';

class SelectRoomScreen extends StatefulWidget {
  const SelectRoomScreen({super.key});  

  @override
  State<SelectRoomScreen> createState() => _SelectRoomScreenState();
}

class _SelectRoomScreenState extends State<SelectRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<SearchHotelController>();
  final dateController = Get.find<HotelDateController>();
  final Map<int, dynamic> selectedRooms = {};
  final guestsController = Get.find<GuestsController>();
  final selectRoomController = Get.put(SelectRoomController());
  final Bookingcontroller = Get.put(BookingController());

  final apiService = ApiServiceHotel();
  bool isLoading = false;
  int? loadingRoomIndex; // Track which room is currently loading

  Future<void> handleBookNow() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract rate keys from selected rooms
      List<String> rateKeys = [];

      selectedRooms.forEach((roomIndex, roomData) {
        if (roomData['rates'] != null && roomData['rates'].isNotEmpty) {
          String? rateKey = roomData['rates'][0]['rateKey']?.toString();
          if (rateKey != null && rateKey.isNotEmpty) {
            rateKeys.add(rateKey);
          }
        }
      });

      if (rateKeys.isEmpty) {
        _showErrorDialog('No valid rate keys found for selected rooms.');
        return;
      }

      print('Rate keys to be checked: $rateKeys');

      var response = await apiService.checkRate(rateKeys: rateKeys);

      if (response != null) {
        Bookingcontroller.buying_price.value = response['hotel']['totalNet'];
        print('the buying rate is ${Bookingcontroller.buying_price.value}');

        // Store the response in the controller
        selectRoomController.storePrebookResponse(response);

        // Navigate to next screen or handle success case
        Get.to(() => BookingHotelScreen());
      } else {
        _showErrorDialog(
            'Failed to validate room availability. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(
          'An error occurred while processing your booking. Please try again.');
      print('Booking error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: guestsController.roomCount.value,
      vsync: this,
    );

    // Listen to tab changes
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

 void selectRoom(int roomIndex, dynamic room) {
  setState(() {
    selectedRooms[roomIndex] = room;

    // Store the complete room data including the rate key
    if (room['rates'] != null && room['rates'].isNotEmpty) {
      String? rateKey = room['rates'][0]['rateKey']?.toString();
      if (rateKey != null && rateKey.isNotEmpty) {
        selectRoomController.storeRateKey(roomIndex, rateKey);
      }
    }

    // Update the controller
    Get.find<SearchHotelController>().updateSelectedRoom(roomIndex, room);

    // Update total rooms price
    selectRoomController.updateTotalRoomsPrice(selectedRooms);

    // Move to next tab if available
    if (roomIndex < guestsController.roomCount.value - 1) {
      _tabController.animateTo(roomIndex + 1);
    }
  });
} 

  // Update the observable total rooms price
 
  bool get allRoomsSelected =>
      selectedRooms.length == guestsController.roomCount.value;

  // Updated method to handle single room booking with loading state
  void bookSingleRoom(dynamic room) async {
    // First select the room
    selectRoom(0, room);
    
    // Set the loading state for this specific room
    setState(() {
      loadingRoomIndex = controller.roomsdata.indexOf(room);
      isLoading = true;
    });
    
    try {
      // Extract rate key from selected room
      List<String> rateKeys = [];
      
      if (room['rates'] != null && room['rates'].isNotEmpty) {
        String? rateKey = room['rates'][0]['rateKey']?.toString();
        if (rateKey != null && rateKey.isNotEmpty) {
          rateKeys.add(rateKey);
        }
      }
      
      if (rateKeys.isEmpty) {
        _showErrorDialog('No valid rate key found for selected room.');
        return;
      }
      
      print('Rate key to be checked: $rateKeys');
      
      var response = await apiService.checkRate(rateKeys: rateKeys);
      
      if (response != null) {
        Bookingcontroller.buying_price.value = response['hotel']['totalNet'];
        print('the buying rate is ${Bookingcontroller.buying_price.value}');
        
        // Store the response in the controller
        selectRoomController.storePrebookResponse(response);
        
        // Navigate to next screen
        Get.to(() => BookingHotelScreen());
      } else {
        _showErrorDialog('Failed to validate room availability. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while processing your booking. Please try again.');
      print('Booking error: $e');
    } finally {
      // Reset loading state
      setState(() {
        loadingRoomIndex = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Room', style: TextStyle(color: TColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TColors.text),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        bottom: guestsController.roomCount.value > 1
            ? TabBar(
                controller: _tabController,
                tabs: List.generate(
                  guestsController.roomCount.value,
                  (index) => Tab(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Room ${index + 1}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (selectedRooms.containsKey(index))
                            const Icon(Icons.check_circle, size: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                labelColor: TColors.primary,
                unselectedLabelColor: TColors.grey,
                indicatorColor: TColors.primary,
              )
            : null,
      ),
      body: Obx(() {
        if (controller.roomsdata.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        // Group rooms by roomName
        Map<String, List<dynamic>> groupedRooms = {};
        for (var room in controller.roomsdata) {
          String roomName = room['roomName'] ?? 'Unknown Room';
          if (!groupedRooms.containsKey(roomName)) {
            groupedRooms[roomName] = [];
          }
          groupedRooms[roomName]!.add(room);
        }

        bool isSingleRoom = guestsController.roomCount.value == 1;

        if (guestsController.roomCount.value > 1) {
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    guestsController.roomCount.value,
                    (roomIndex) => SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHotelInfo(),
                          ...groupedRooms.entries
                              .map((entry) => RoomTypeSection(
                                    roomTypeName: entry.key,
                                    rooms: entry.value,
                                    nights: dateController.nights.value,
                                    onRoomSelected: (room) =>
                                        selectRoom(roomIndex, room),
                                    isSelected: (room) =>
                                        selectedRooms[roomIndex] == room,
                                    isSingleRoom: false,
                                  )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Single room view with "Book Now" buttons directly on rooms
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfo(),
                ...groupedRooms.entries.map((entry) => RoomTypeSection(
                      roomTypeName: entry.key,
                      rooms: entry.value,
                      nights: dateController.nights.value,
                      onRoomSelected: (room) => bookSingleRoom(room), 
                      isSelected: (room) => selectedRooms[0] == room,
                      isSingleRoom: true,
                      loadingRoomIndex: loadingRoomIndex, // Pass loading state
                    )),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar:
          guestsController.roomCount.value > 1 && allRoomsSelected
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: Get.width,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleBookNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isLoading ? 'Checking Availability...' : 'Book Now',
                            style: const TextStyle(
                              color: TColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      if (isLoading)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: TColors.secondary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : null,
    );
  }

  Widget _buildHotelInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: TColors.background2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.hotelName.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                controller.zoneName.value,
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Text(
                controller.destinationName.value,
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: TColors.primary, size: 18),
              SizedBox(width: 4),
              Text(
                '${controller.categoryName.value} Star Hotel',
                style: TextStyle(
                  color: TColors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RoomTypeSection extends StatefulWidget {
  final String roomTypeName;
  final List<dynamic> rooms;
  final int nights;
  final Function(dynamic) onRoomSelected;
  final Function(dynamic) isSelected;
  final bool isSingleRoom;
  final int? loadingRoomIndex;

  const RoomTypeSection({
    super.key,
    required this.roomTypeName,
    required this.rooms,
    required this.nights,
    required this.onRoomSelected,
    required this.isSelected,
    this.isSingleRoom = false,
    this.loadingRoomIndex,
  });

  @override
  State<RoomTypeSection> createState() => _RoomTypeSectionState();
}

class _RoomTypeSectionState extends State<RoomTypeSection> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: TColors.secondary.withOpacity(0.3),
          child: Row(
            children: [
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.background4,
                    border: Border.all(color: TColors.background3),
                  ),
                  child: Center(
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 16,
                      color: TColors.background3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.roomTypeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          ...widget.rooms.asMap().entries.map((entry) {
            final dynamic room = entry.value;
            
            // Check if this specific room is being loaded
            bool isRoomLoading = widget.loadingRoomIndex != null && 
                widget.rooms.indexOf(room) == widget.loadingRoomIndex;
                
            return RoomCard(
              room: room,
              nights: widget.nights,
              onSelect: widget.onRoomSelected,
              isSelected: widget.isSelected(room),
              showBookNowButton: widget.isSingleRoom,
              isLoading: isRoomLoading, // Pass the loading state
            );
          }),
      ],
    );
  }
}