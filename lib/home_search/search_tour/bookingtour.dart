import 'package:flight_bocking/home_search/search_tour/tourcontroler.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingTour extends StatelessWidget {
  final PriceController priceController = Get.put(PriceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Southern Tales Booking'),
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with image, place name, and description
            Stack(
              children: [
                Image.asset(
                  'assets/img/cardbg/2.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: Colors.black54,
                    child: Text(
                      'Southern Tales: Full-day Tour',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'In this 8-hour private tour, you will explore the Southwest of Mauritius including a visit to Grand Bassin to see the Hindu Temple & the gigantic statue of Lord Shiva. Then head to Alexandra Falls to see the view of the south, waterfall & its dense valley.',
                    style: TextStyle(fontSize: 16, color: TColors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Choose a Car:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(() => Column(
                        children: [
                          RadioListTile(
                            activeColor: TColors.primary,
                            title: Text('4-Seater Car (PKR 15390)'),
                            value: '4-seater',
                            groupValue: priceController.selectedCar.value,
                            onChanged: (value) {
                              priceController.updatePrice('4-seater', 15390);
                            },
                          ),
                          RadioListTile(
                            activeColor: TColors.primary,
                            title: Text('6-Seater Car (PKR 20310)'),
                            value: '6-seater',
                            groupValue: priceController.selectedCar.value,
                            onChanged: (value) {
                              priceController.updatePrice('6-seater', 20310);
                            },
                          ),
                          RadioListTile(
                            activeColor: TColors.primary,
                            title: Text('12-Seater Minivan (PKR 29325)'),
                            value: '12-seater',
                            groupValue: priceController.selectedCar.value,
                            onChanged: (value) {
                              priceController.updatePrice('12-seater', 29325);
                            },
                          ),
                        ],
                      )),
                  SizedBox(height: 20),
                  Text(
                    'Pickup Time:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TColors.primary),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: '08:00 AM', child: Text('08:00 AM')),
                      DropdownMenuItem(
                          value: '09:00 AM', child: Text('09:00 AM')),
                      DropdownMenuItem(
                          value: '10:00 AM', child: Text('10:00 AM')),
                    ],
                    onChanged: (value) {},
                    hint: Text('Select Pickup Time'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Drop Time:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TColors.text,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TColors.primary),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                          value: '05:00 PM', child: Text('05:00 PM')),
                      DropdownMenuItem(
                          value: '06:00 PM', child: Text('06:00 PM')),
                      DropdownMenuItem(
                          value: '07:00 PM', child: Text('07:00 PM')),
                    ],
                    onChanged: (value) {},
                    hint: Text('Select Drop Time'),
                  ),
                  SizedBox(height: 20),
                  Obx(() => Text(
                        'Total Price: PKR ${priceController.totalPrice.value}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      )),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Add booking logic here
                      Get.snackbar('Booking Confirmed',
                          'You have selected ${priceController.selectedCar.value} with a total price of PKR ${priceController.totalPrice.value}.');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(fontSize: 18, color: TColors.background),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
