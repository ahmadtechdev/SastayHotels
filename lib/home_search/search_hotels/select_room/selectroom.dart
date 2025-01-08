import 'package:flight_bocking/home_search/search_hotels/booking_hotel/booking_hotel.dart';
import 'package:flight_bocking/home_search/search_hotels/search_hotel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:intl/intl.dart';

import '../../../services/api_service.dart';
import '../../booking_card/forms/hotel/guests/guests_controller.dart';
import '../../booking_card/forms/hotel/hotel_date_controller.dart';
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
  final apiService = ApiService();
  bool isLoading = false;

  Future<void> handleBookNow() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract rate keys from selected rooms
      List<String> rateKeys = selectedRooms.values
          .map((room) => room['rateKey'].toString())
          .toList();

      // Get the group code from the first selected room
      int groupCode = selectedRooms.values.first['groupCode'] as int;

      // Make the prebook API call
      var response = await apiService.prebook(
        sessionId: controller.sessionId.value,
        hotelCode: controller.hotelCode.value,
        groupCode: groupCode,
        currency: "USD",
        rateKeys: rateKeys,
      );

      // Store the response in the controller
      if (response != null) {
        selectRoomController.storePrebookResponse(response);

        bool isSoldOut = response['isSoldOut'] ?? false;
        bool isPriceChanged = response['isPriceChanged'] ?? false;
        bool isBookable = response['isBookable'] ?? false;

        if (isSoldOut) {
          _showErrorDialog(
              'Sorry, one or more selected rooms are no longer available.');
        } else if (isPriceChanged) {
          _showErrorDialog(
              'The price for one or more rooms has changed. Please review the updated prices.');
        } else if (!isBookable) {
          _showErrorDialog(
              'One or more rooms are not currently bookable. Please try different rooms.');
        } else {
          // All validations passed, proceed to booking
          Get.to(() => BookingHotelScreen());
        }
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
    // Update the selected room data in the controller
    Get.find<SearchHotelController>().updateSelectedRoom(roomIndex, room);
    if (roomIndex < guestsController.roomCount.value - 1) {
      _tabController.animateTo(roomIndex + 1);
    }
  });
}

  bool get allRoomsSelected =>
      selectedRooms.length == guestsController.roomCount.value;

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
          // Single room view (original layout)
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfo(),
                ...groupedRooms.entries.map((entry) => RoomTypeSection(
                      roomTypeName: entry.key,
                      rooms: entry.value,
                      nights: dateController.nights.value,
                      onRoomSelected: (room) => selectRoom(0, room),
                      isSelected: (room) => selectedRooms[0] == room,
                    )),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar:
          guestsController.roomCount.value >= 1 && allRoomsSelected
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
          const Row(
            children: [
              Icon(Icons.star, color: TColors.primary, size: 18),
              SizedBox(width: 4),
              Text(
                '4 Star Hotel',
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

  const RoomTypeSection({
    super.key,
    required this.roomTypeName,
    required this.rooms,
    required this.nights,
    required this.onRoomSelected,
    required this.isSelected,
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
          ...widget.rooms.map((room) => RoomCard(
                room: room,
                nights: widget.nights,
                onSelect: widget.onRoomSelected,
                isSelected: widget.isSelected(room),
              )),
      ],
    );
  }
}


