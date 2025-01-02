import 'package:flight_bocking/home_search/search_hotels/BookingHotle/BookingHotle.dart';
import 'package:flight_bocking/home_search/search_hotels/search_hotle_Controler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';

class SelectRoomScreen extends StatelessWidget {
  const SelectRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchHotelController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Room', style: TextStyle(color: TColors.text)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColors.text),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.roomsdata.isEmpty) {
          return Center(
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

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: TColors.background2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.hotlename.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: TColors.primary, size: 18),
                        const SizedBox(width: 4),
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
              ),
              ...groupedRooms.entries.map((entry) =>
                  RoomTypeSection(
                    roomTypeName: entry.key,
                    rooms: entry.value,
                    nights: controller.nights.value,
                  ),
              ).toList(),
            ],
          ),
        );
      }),
    );
  }
}

class RoomTypeSection extends StatefulWidget {
  final String roomTypeName;
  final List<dynamic> rooms;
  final int nights;

  const RoomTypeSection({
    Key? key,
    required this.roomTypeName,
    required this.rooms,
    required this.nights,
  }) : super(key: key);

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
          )).toList(),
      ],
    );
  }
}

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final int nights;

  const RoomCard({
    Key? key,
    required this.room,
    required this.nights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pricePerNight = room['price']['net'] ?? 0.0;
    final totalPrice = pricePerNight * nights;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Row(

                      children: [
                        _buildRoomIcon(),

                        const SizedBox(width: 8),
                        Row(
                          children: [

                            Text(
                              room['meal'] ?? 'Not Available',
                              style: TextStyle(color: TColors.text, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),

                    _buildBadge(room['rateType'] ?? 'Unknown'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, size: 16, color: TColors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Per Night',
                              style: TextStyle(
                                color: TColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${pricePerNight.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calculate, size: 16, color: TColors.grey),
                            const SizedBox(width: 4),
                            Text(
                              // 'Total for $nights Nights',
                              'Total',
                              style: TextStyle(
                                color: TColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (room['remarks']?['remark'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    room['remarks']['remark'][0]['text'] ?? '',
                    style: TextStyle(
                      color: TColors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.to(BookingScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Book Name',
                      style: TextStyle(
                        color: TColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.hotel,
        color: TColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildBadge(String text) {
    final isRefundable = text.toLowerCase() == 'refundable';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRefundable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isRefundable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}