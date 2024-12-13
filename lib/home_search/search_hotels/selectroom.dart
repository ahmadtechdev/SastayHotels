import 'package:flight_bocking/home_search/search_hotels/BookingHotle/BookingHotle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';

class SelectRoomScreen extends StatelessWidget {
  SelectRoomScreen();

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> rooms = [
      {
        'type': 'Deluxe Room',
        'price': 5000,
        'image': 'assets/img/cardbg/2.jpg'
      },
      {'type': 'Suite', 'price': 8000, 'image': 'assets/img/cardbg/3.jpg'},
      {
        'type': 'Single Room',
        'price': 3000,
        'image': 'assets/img/cardbg/4.jpg'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Room', style: TextStyle(color: TColors.text)),
        // backgroundColor: TColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: TColors.text),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hotel name',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColors.primary),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  var room = rooms[index];
                  return RoomCard(room: room);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;

  RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              room['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns content to the left
              children: [
                Text(
                  room['type'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: RS${room['price']} / Per Night',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Get.to(BookingScreen());
                // Handle room selection action
                Get.snackbar(
                    'Room Selected', '${room['type']} has been selected!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 40),
              ),
              child:
                  Text('Book Now', style: TextStyle(color: TColors.secondary)),
            ),
          ),
        ],
      ),
    );
  }
}
