import 'package:flight_bocking/home_search/search_tour/conformbooking.dart';
import 'package:flight_bocking/home_search/search_tour/tourcontroler.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:flight_bocking/widgets/date_selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingTour extends StatelessWidget {
  final Tourcontroler controler = Get.put(Tourcontroler());
  final RxInt adultCount = 0.obs;
  final RxInt childCount = 0.obs;

   BookingTour({super.key});

  @override
  Widget build(BuildContext context) {
    // Pricing constants
    int adultPrice = 80085;
    int childPrice = 41895;

    // Update ticket price dynamically
    controler.updateTicketPrice(
      adultCount.value,
      childCount.value,
      adultPrice,
      childPrice,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Booking'),
        // backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with image and description
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
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      color: Colors.black54,
                      child: const Text(
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
                child: Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'In this 8-hour private tour, you will explore the Southwest of Mauritius. The journey includes visits to stunning beaches, historical landmarks, and beautiful nature reserves. You will enjoy breathtaking views of the island while learning about its rich cultural heritage and unique wildlife. Our knowledgeable local guides will ensure you have an unforgettable experience, sharing insights into the island’s history, traditions, and hidden gems.',
                        style: TextStyle(fontSize: 16, color: TColors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Starting From: PKR 800,85',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: TColors.primary),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Ticket Only', child: Text('Ticket Only')),
                          DropdownMenuItem(
                              value: 'Ticket + Private Transfer',
                              child: Text('Ticket + Private Transfer')),
                        ],
                        onChanged: (value) {},
                        hint: const Text('Select Ticket'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      Obx(() => SizedBox(
                            height: 55,
                            child: DateSelectionField(
                              initialDate: controler.departureDate.value,
                              fontSize: 12,
                              onDateChanged: (date) {
                                controler.updateDepartureDate(date);
                              },
                              firstDate: DateTime.now(),
                            ),
                          )),
                      const SizedBox(height: 20),
                      const Text(
                        'Adults',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      DropdownButtonFormField<int>(
                        value: adultCount.value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: TColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: TColors.primary),
                          ),
                        ),
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text('$index'),
                          ),
                        ),
                        onChanged: (value) => adultCount.value = value!,
                        hint: const Text('Select Adults'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Children',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      DropdownButtonFormField<int>(
                        value: childCount.value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.child_care,
                            color: TColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: TColors.primary),
                          ),
                        ),
                        items: List.generate(
                          10,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text('$index'),
                          ),
                        ),
                        onChanged: (value) => childCount.value = value!,
                        hint: const Text('Select Children'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Choose a Car:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: TColors.text,
                        ),
                      ),
                      Obx(() => Column(
                            children: [
                              RadioListTile(
                                activeColor: TColors.primary,
                                title: const Row(
                                  children: [
                                    Icon(Icons.car_rental,
                                        color: TColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '4-Seater Car (PKR 15390)',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                value: '4-seater',
                                groupValue: controler.selectedCar.value,
                                onChanged: (value) {
                                  controler.updateCarPrice('4-seater', 15390);
                                },
                              ),
                              RadioListTile(
                                activeColor: TColors.primary,
                                title: const Row(
                                  children: [
                                    Icon(Icons.car_rental,
                                        color: TColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '6-Seater Car (PKR 20310)',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                value: '6-seater',
                                groupValue: controler.selectedCar.value,
                                onChanged: (value) {
                                  controler.updateCarPrice('6-seater', 20310);
                                },
                              ),
                              RadioListTile(
                                activeColor: TColors.primary,
                                title: const Row(
                                  children: [
                                    Icon(Icons.directions_bus,
                                        color: TColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      '12-Seater Minivan (PKR 29325)',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                value: '12-seater',
                                groupValue: controler.selectedCar.value,
                                onChanged: (value) {
                                  controler.updateCarPrice('12-seater', 29325);
                                },
                              ),
                            ],
                          )),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: TColors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Adult Price: ${adultCount.value} x PKR $adultPrice = PKR ${adultCount.value * adultPrice}',
                              style:
                                  const TextStyle(fontSize: 16, color: TColors.text),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Total Child Price: ${childCount.value} x PKR $childPrice = PKR ${childCount.value * childPrice}',
                              style:
                                  const TextStyle(fontSize: 16, color: TColors.text),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Private Transfer: PKR ${controler.carPrice.value}',
                              style:
                                  const TextStyle(fontSize: 16, color: TColors.text),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total Price: PKR ${controler.totalPrice.value}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(ConformBooking());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
