import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'search_hotel_controller.dart';
import 'select_room/selectroom.dart';

class HotelScreen extends StatefulWidget {
  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  @override
  Widget build(BuildContext context) {
    final SearchHotelController controller = Get.find<SearchHotelController>();
    Widget buildRatingBar(double rating) {
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(
          Icons.star,
          color: Colors.orange,
        ),
        itemCount: 5,
        itemSize: 20.0,
        direction: Axis.horizontal,
      );
    }

    void showFilterSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Obx(() => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Rating',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: List.generate(6, (index) {
                          if (index == 5) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: !controller.selectedRatings
                                      .contains(true),
                                  onChanged: (value) {
                                    if (value == true) {
                                      controller.resetFilters();
                                    }
                                  },
                                  activeColor: TColors.primary,
                                ),
                                const Text('All Hotels'),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Checkbox(
                                value: controller.selectedRatings[index],
                                onChanged: (value) {
                                  controller.selectedRatings[index] = value!;
                                },
                                activeColor: TColors.primary,
                              ),
                              buildRatingBar((5 - index).toDouble()),
                              const SizedBox(width: 8),
                              Text(
                                '(${controller.hotels.where((hotel) => hotel['rating'] == 5 - index).length})',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Get.back();

                              // setState(() {
                              //   selectedOption = 'Recommended';
                              // });
                              controller.resetFilters();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Reset'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.filterByRating();
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: TColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Section with Search Text Field and Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Text Field
                SizedBox(
                  height: 50,
                  child: TextField(
                    style: const TextStyle(color: TColors.black),
                    onChanged: (value) {
                      controller.searchHotelsByName(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for hotels...',
                      hintStyle: const TextStyle(color: TColors.black),
                      prefixIcon:
                          const Icon(Icons.search, color: TColors.primary),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: TColors.black),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                // Buttons: Filter, Sort, Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(context, Icons.filter_list, 'Filter', () {
                      showFilterSheet(context);
                    }),
                    _buildButton(context, Icons.sort, 'Sort', () {
                      _showSortOptionsBottomSheet(context, controller);
                      // Implement Sort Action
                    }),
                    _buildButton(context, Icons.attach_money, 'Price', () {
                      _showPriceRangeBottomSheet(context, controller);
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Hotel List Section
          Expanded(
            child: Obx(() {
              var hotels = controller.hotels;
              if (hotels.isEmpty) {
                return const Center(
                  child: Text(
                    'No hotels found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: hotels.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return HotelCard(hotel: hotels[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: TColors.text),
      label: Text(label, style: const TextStyle(color: TColors.text)),
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSortOptionsBottomSheet(
      BuildContext context, SearchHotelController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        String selectedOption = 'Recommended';

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  RadioListTile<String>(
                    value: 'Price (low to high)',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Price (low to high)'),
                    activeColor: TColors.primary,
                  ),
                  RadioListTile<String>(
                    value: 'Price (high to low)',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Price (high to low)'),
                    activeColor: TColors.primary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back();

                          //
                          controller.resetFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.sortHotels(selectedOption);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPriceRangeBottomSheet(
      BuildContext context, SearchHotelController controller) {
    // Calculate min and max prices dynamically from the hotels list
    final prices = controller.hotels
        .map((hotel) =>
            double.parse(hotel['price'].toString().replaceAll(',', '').trim()))
        .toList();

    double minPrice =
        prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
    double maxPrice =
        prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b) : 0.0;

    double lowerValue = minPrice;
    double upperValue = maxPrice;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Price Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(lowerValue, upperValue),
                    min: minPrice,
                    max: maxPrice,
                    divisions: 10,
                    labels: RangeLabels(
                      '\$${lowerValue.round()}',
                      '\$${upperValue.round()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        lowerValue = values.start;
                        upperValue = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            lowerValue = minPrice;
                            upperValue = maxPrice;
                            controller.resetFilters();
                            Get.back();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.filterByPriceRange(lowerValue, upperValue);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HotelCard extends StatelessWidget {
  final Map hotel;

  HotelCard({super.key, required this.hotel});

  final SearchHotelController controller = Get.find<SearchHotelController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildHotelImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel['name'] ?? 'Unknown Hotel',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hotel['address'] ?? 'Address not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => MapScreen(
                            latitude: double.tryParse(
                                    hotel['latitude']?.toString() ?? '') ??
                                0.0,
                            longitude: double.tryParse(
                                    hotel['longitude']?.toString() ?? '') ??
                                0.0,
                            hotelName: hotel['name'] ?? 'Unknown Hotel',
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: TColors.primary,
                        size: 30,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: (hotel['rating'] ?? 3.0).toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 15,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    const Spacer(),
                    Text(
                      'PKR ${(double.parse(hotel['price'] ?? '0') * 278.5).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: TColors.text,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Update hotel information
                controller.hotelCode.value = hotel['hotelCode'].toString();
                controller.hotelCity.value = hotel['hotelCity'] ?? '';
                controller.hotelName.value = hotel['name'] ?? 'Unknown Hotel';
                controller.destinationName.value = hotel['address'] ?? '';
                controller.zoneName.value = hotel['zoneName'] ?? '';
                controller.categoryName.value = hotel['rating'].toString();
                controller.lat.value = hotel['latitude'];
                controller.lon.value = hotel['longitude'];

                // Clear previous room data
                controller.roomsdata.clear();

                // Transform rooms data from the original response
                final hotelData = controller
                    .originalResponse.value['hotels']?['hotels']
                    ?.firstWhere(
                        (h) =>
                            h['code'].toString() ==
                            hotel['hotelCode'].toString(),
                        orElse: () => null);

                if (hotelData != null && hotelData['rooms'] != null) {
                  final roomsData = (hotelData['rooms'] as List).map((room) {
                    final rates = (room['rates'] as List?)?.map((rate) {
                          return {
                            'rateKey': rate['rateKey'],
                            'rateClass': rate['rateClass'],
                            'rateType': rate['rateType'],
                            'boardCode': rate['boardCode'],
                            'boardName': rate['boardName'],
                            'meal': rate['boardName'],
                            'price': {
                              'net': double.tryParse(
                                      rate['net']?.toString() ?? '0') ??
                                  0,
                              'total': double.tryParse(
                                      rate['net']?.toString() ?? '0') ??
                                  0,
                            },
                            'cancellationPolicies':
                                rate['cancellationPolicies'] ?? [],
                          };
                        }).toList() ??
                        [];

                    return {
                      'roomCode': room['code'],
                      'roomName': room['name'],
                      'rates': rates,
                    };
                  }).toList();

                  controller.roomsdata.value = roomsData;
                }

                controller.filterhotler();
                Get.to(() => const SelectRoomScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Select Room',
                  style: TextStyle(color: TColors.secondary)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHotelImage() {
    String imageUrl = hotel['image'] ?? '';

    // Check if the image is a URL
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(
              color: TColors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/img/cardbg/4.jpg',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // If not a URL, assume it's a local asset path
      return Image.asset(
        imageUrl.isEmpty ? 'assets/img/cardbg/4.jpg' : imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hotelName,
  });

  @override
  Widget build(BuildContext context) {
    final CameraPosition initialPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 15,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: TColors.primary,
          ),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: initialPosition,
        markers: {
          Marker(
            markerId: MarkerId(hotelName),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: hotelName),
          ),
        },
      ),
    );
  }
}
