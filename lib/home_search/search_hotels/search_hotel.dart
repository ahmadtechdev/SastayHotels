import 'package:flight_bocking/home_search/search_hotels/selectroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:flight_bocking/home_search/search_hotels/search_hotle_Controler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelScreen extends StatefulWidget {
  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  @override
  Widget build(BuildContext context) {
    final SearchHotelController controller = Get.put(SearchHotelController());
    Widget buildRatingBar(double rating) {
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => Icon(
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
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Rating',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
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
                                Text('All Hotels'),
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
                              SizedBox(width: 8),
                              Text(
                                '(${controller.hotels.where((hotel) => hotel['rating'] == 5 - index).length})',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 16),
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
                            child: Text('Reset'),
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
                            child: Text('Confirm'),
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
          icon: Icon(
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
                Container(
                  height: 50,
                  child: TextField(
                    style: TextStyle(color: TColors.black),
                    onChanged: (value) {
                      controller.searchHotelsByName(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for hotels...',
                      hintStyle: TextStyle(color: TColors.black),
                      prefixIcon: Icon(Icons.search, color: TColors.primary),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: TColors.black),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),
                // Buttons: Filter, Sort, Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton(context, Icons.filter_list, 'Filter', () {
                      showFilterSheet(context);
                    }),
                    _buildButton(context, Icons.sort, 'Sort', () {
                      _showSortOptionsBottomSheet(context);
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
                return Center(
                  child: Text(
                    'No hotels found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: hotels.length,
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
      label: Text(label, style: TextStyle(color: TColors.text)),
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primary.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSortOptionsBottomSheet(BuildContext context) {
    final SearchHotelController controller = Get.find<SearchHotelController>();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
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
                  SizedBox(height: 16),
                  Text(
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
                    title: Text('Price (low to high)'),
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
                    title: Text('Price (high to low)'),
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
                        child: Text('Reset'),
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
                        child: Text('Confirm'),
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
      shape: RoundedRectangleBorder(
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
                  SizedBox(height: 16),
                  Text(
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
                  SizedBox(height: 16),
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
                        child: Text('Reset'),
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
                        child: Text('Confirm'),
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

  HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              hotel['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          hotel['address'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          MapScreen(
                            latitude: hotel['latitude'],
                            longitude: hotel['longitude'],
                            hotelName: hotel['name'],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.location_on_rounded,
                        color: TColors.primary,
                        size: 30,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: hotel['rating'].toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 15,
                      itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    Spacer(),
                    Text(
                      'RS${hotel['price']} / Per Night',
                      style: TextStyle(fontSize: 15, color: Colors.red),
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
                Get.to(SelectRoomScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text('Select Room',
                  style: TextStyle(color: TColors.secondary)),
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String hotelName;

  MapScreen({
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
          icon: Icon(
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
