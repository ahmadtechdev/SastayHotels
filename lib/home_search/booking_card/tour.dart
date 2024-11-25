import 'package:flutter/material.dart';
import '../../widgets/colors.dart';

class Tour {
  final String name;
  final String description;
  final double price;
  final String image;
  final String city;
  final int maxPeople;

  Tour({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.city,
    required this.maxPeople,
  });
}

class ToursPage extends StatefulWidget {
  const ToursPage({super.key});

  @override
  State<ToursPage> createState() => _ToursPageState();
}

class _ToursPageState extends State<ToursPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Tour> filteredTours = [];

  final List<Tour> allTours = [
    Tour(
      name: 'Mountain Adventure Trek',
      description:
          'Experience breathtaking views on this guided mountain trek through pristine wilderness. Perfect for nature enthusiasts and photographers.',
      price: 12999,
      city: "Faisalabad",
      image: 'assets/img/cardbg/1.jpg',
      maxPeople: 8,
    ),
    Tour(
      name: 'Cultural Heritage Walk',
      description:
          'Discover local history and traditions through this immersive walking tour of historic sites and cultural landmarks.',
      price: 8499,
      city: "Lahore",
      image: 'assets/img/cardbg/2.jpg',
      maxPeople: 12,
    ),
    Tour(
      name: 'Wildlife Safari Experience',
      description:
          'Get up close with exotic wildlife in their natural habitat. Includes professional guide and photography opportunities.',
      price: 15999,
      city: "Bahawalpur",
      image: 'assets/img/cardbg/3.jpg',
      maxPeople: 6,
    ),
    Tour(
      name: 'Beach Paradise Tour',
      description:
          'Visit the most beautiful beaches with crystal clear waters. Includes snorkeling and beach activities.',
      price: 9999,
      city: "Karachi",
      image: 'assets/img/cardbg/4.jpg',
      maxPeople: 10,
    ),
    Tour(
      name: 'Food & Wine Discovery',
      description:
          'Taste local delicacies and wines while learning about regional cuisine and cooking traditions.',
      price: 7499,
      city: "Multan",
      image: 'assets/img/cardbg/5.jpg',
      maxPeople: 8,
    ),
    Tour(
      name: 'Adventure Sports Package',
      description:
          'Get your adrenaline pumping with activities like zip-lining, rock climbing, and river rafting.',
      price: 13999,
      city: "Islamabad",
      image: 'assets/img/cardbg/6.jpg',
      maxPeople: 6,
    ),
    Tour(
      name: 'Island Hopping Experience',
      description:
          'Visit multiple exotic islands in one day. Includes boat ride, snorkeling, and lunch.',
      price: 11999,
      city: "Gwadar",
      image: 'assets/img/cardbg/7.jpg',
      maxPeople: 15,
    ),
    Tour(
      name: 'Sunset Desert Safari',
      description:
          'Experience the magic of the desert at sunset with camel rides and traditional dinner.',
      price: 14999,
      city: "Cholistan",
      image: 'assets/img/cardbg/8.jpg',
      maxPeople: 10,
    ),
    Tour(
      name: 'Historical Monuments Tour',
      description:
          'Visit ancient monuments and learn about their fascinating history from expert guides.',
      price: 6999,
      city: "Taxila",
      image: 'assets/img/cardbg/9.jpg',
      maxPeople: 12,
    ),
    Tour(
      name: 'Rainforest Adventure',
      description:
          'Explore the diverse ecosystem of the rainforest with guided walks and canopy tours.',
      price: 16999,
      city: "Murree",
      image: 'assets/img/cardbg/10.jpg',
      maxPeople: 8,
    ),
    Tour(
      name: 'Rainforest Adventure',
      description:
          'Explore the diverse ecosystem of the rainforest with guided walks and canopy tours.',
      price: 16999,
      city: "Nathia Gali",
      image: 'assets/img/cardbg/11.jpg',
      maxPeople: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    filteredTours = allTours;
    _searchController.addListener(_filterTours);
  }

  void _filterTours() {
    if (_searchController.text.isEmpty) {
      setState(() => filteredTours = allTours);
    } else {
      setState(() {
        filteredTours = allTours
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
                                        'Price for childs',
                                        style: TextStyle(
                                          color: TColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'PKR ${tour.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: TColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Price for Adults',
                                        style: TextStyle(
                                          color: TColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'PKR ${tour.price.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: TColors.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
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
