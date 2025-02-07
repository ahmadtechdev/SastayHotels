import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/colors.dart';
import 'car_booking.dart';
class Car {
  final String name;
  final String description;
  final double price;
  final String image;
  final String city;
  final int maxPeople;

  Car({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.city,
    required this.maxPeople,
  });
}

class SearchCars extends StatefulWidget {
  const SearchCars({super.key});

  @override
  State<SearchCars> createState() => SearchCarsState();
}

class SearchCarsState extends State<SearchCars> {
  final TextEditingController _searchController = TextEditingController();
  List<Car> filteredTours = [];

  final List<Car> allCars = [
    Car(
      name: 'Mountain Adventure Car',
      description:
          'Experience breathtaking views in this off-road car, perfect for mountain treks and rugged paths.',
      price: 12999,
      city: "Faisalabad",
      image: 'assets/img/cars/car1.png',
      maxPeople: 8,
    ),
    Car(
      name: 'Luxury Sedan Ride',
      description:
          'Enjoy a smooth and luxurious ride through the city in this high-end sedan.',
      price: 8499,
      city: "Lahore",
      image: 'assets/img/cars/car2.png',
      maxPeople: 4,
    ),
    Car(
      name: 'Safari Jeep Tour',
      description:
          'Get up close with exotic wildlife in this all-terrain jeep, built for safari adventures.',
      price: 15999,
      city: "Bahawalpur",
      image: 'assets/img/cars/car1.png',
      maxPeople: 6,
    ),
    Car(
      name: 'Beach Buggy Ride',
      description:
          'Feel the thrill of beach driving in this special beach buggy, designed for coastal fun.',
      price: 9999,
      city: "Karachi",
      image: 'assets/img/cars/car2.png',
      maxPeople: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    filteredTours = allCars;
    _searchController.addListener(_filterTours);
  }

  void _filterTours() {
    if (_searchController.text.isEmpty) {
      setState(() => filteredTours = allCars);
    } else {
      setState(() {
        filteredTours = allCars
            .where((tour) => tour.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // Container(
        // height: 600, // Fixed height for the tours container
        // color: Colors.grey[100],
        // child:
        Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tours...',
              prefixIcon: const Icon(Icons.search, color: TColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: TColors.primary, width: 2),
              ),
            ),
          ),
        ),
        // Tours List
        // Expanded(
        //   child:
        SingleChildScrollView(
          // Wrap ListView with SingleChildScrollView
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true, // Make ListView take only needed space
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTours.length,
                itemBuilder: (context, index) {
                  final tour = filteredTours[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: TColors.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container with overlay
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(tour.image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Text(
                                tour.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.background,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tour.city,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: TColors.background,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Tour Details Section
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tour.description,
                                style: const TextStyle(
                                  color: TColors.text,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Capacity',
                                        style: TextStyle(
                                          color: TColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${tour.maxPeople.toStringAsFixed(0)} Seater',
                                        style: const TextStyle(
                                          color: TColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Price',
                                        style: TextStyle(
                                          color: TColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'PKR ${tour.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: TColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                // Add padding around the button
                                child: SizedBox(
                                  width: double.infinity,
                                  // Makes the button take full width
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.to(CarBooking());
                                      // Add booking functionality
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: TColors.primary,
                                      foregroundColor: TColors.background,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(48),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        size: 16),
                                    label: const Text(
                                      'Book Now',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // ),
      ],
    )
        // )
        ;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
