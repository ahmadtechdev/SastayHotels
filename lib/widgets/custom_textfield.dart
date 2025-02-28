import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import 'colors.dart';

class AirportData {
  final String code;
  final String name;
  final String cityName;
  final String countryName;
  final String cityCode;

  AirportData({
    required this.code,
    required this.name,
    required this.cityName,
    required this.countryName,
    required this.cityCode,
  });

  factory AirportData.fromJson(Map<String, dynamic> json) {
    return AirportData(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      cityName: json['city_name'] ?? '',
      countryName: json['country_name'] ?? '',
      cityCode: json['city_code'] ?? '',
    );
  }
}

enum FieldType {
  departure,
  destination,
}

// Create a GetX controller for airport data
class AirportController extends GetxController {
  var airports = <AirportData>[].obs;
  var defaultDepartureAirports = <AirportData>[].obs;
  var defaultDestinationAirports = <AirportData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var filteredAirports = <AirportData>[].obs;

  // Define city codes for departure defaults
  final List<String> departureAirportCodes = [
    "KHI",
    "LHE",
    "ISB",
    "LYP",
    "PEW",
    "MUX",
    "SKT"
  ];

  // Define city codes for destination defaults
  final List<String> destinationAirportCodes = [
    "DXB",
    "JED",
    "MED",
    "LON",
    "CDG",
    "IST",
    "KUL",
    "GYD",
    "BKK"
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAirports();
  }

  Future<void> fetchAirports() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response =
      await http.get(Uri.parse('https://agent1.pk/api.php?type=airports'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] is List) {
          final List<dynamic> airportsData = jsonData['data'];
          airports.value =
              airportsData.map((item) => AirportData.fromJson(item)).toList();

          // Once we have all airports, filter for default lists
          _filterDefaultAirports();
        } else {
          errorMessage.value = 'Invalid data format';
        }
      } else {
        errorMessage.value =
        'Failed to load airports. Status: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _filterDefaultAirports() {
    if (airports.isEmpty) return;

    // Filter for departure airports
    defaultDepartureAirports.value = airports
        .where((airport) => departureAirportCodes.contains(airport.code))
        .toList()
      ..sort((a, b) {
        final indexA = departureAirportCodes.indexOf(a.code);
        final indexB = departureAirportCodes.indexOf(b.code);
        return indexA.compareTo(indexB);
      });

    // Filter for destination airports
    defaultDestinationAirports.value = airports
        .where((airport) => destinationAirportCodes.contains(airport.code))
        .toList()
      ..sort((a, b) {
        final indexA = destinationAirportCodes.indexOf(a.code);
        final indexB = destinationAirportCodes.indexOf(b.code);
        return indexA.compareTo(indexB);
      });

    // Log any missing airports
    if (defaultDepartureAirports.length < departureAirportCodes.length) {
      print(
          'Warning: Could not find all default departure airports in API response.');
      print(
          'Found ${defaultDepartureAirports.length} out of ${departureAirportCodes.length}');
    }

    if (defaultDestinationAirports.length < destinationAirportCodes.length) {
      print(
          'Warning: Could not find all default destination airports in API response.');
      print(
          'Found ${defaultDestinationAirports.length} out of ${destinationAirportCodes.length}');
    }
  }

  void searchAirports(String query, FieldType fieldType) {
    if (query.isEmpty) {
      // Show default airports when search is empty
      filteredAirports.value = fieldType == FieldType.departure
          ? defaultDepartureAirports
          : defaultDestinationAirports;
    } else {
      // Filter all airports based on search query
      final searchQuery = query.toLowerCase();
      filteredAirports.value = airports
          .where((airport) =>
      airport.cityName.toLowerCase().contains(searchQuery) ||
          airport.name.toLowerCase().contains(searchQuery) ||
          airport.code.toLowerCase().contains(searchQuery) ||
          airport.countryName.toLowerCase().contains(searchQuery))
          .toList();
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final String? initialValue;
  final Function(String name, String code)? onCitySelected;
  final TextEditingController controller;
  final FieldType fieldType;

  // Get a singleton instance of the AirportController
  final AirportController airportController = Get.put(AirportController());

  CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.initialValue,
    this.onCitySelected,
    TextEditingController? controller,
    this.fieldType = FieldType.departure,
  })  : controller = controller ?? TextEditingController(text: initialValue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAirportSuggestions(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: TColors.primary),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: TColors.primary, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  void _showAirportSuggestions(BuildContext context) {
    // Initialize with the appropriate default list
    airportController.filteredAirports.value = fieldType == FieldType.departure
        ? airportController.defaultDepartureAirports
        : airportController.defaultDestinationAirports;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fieldType == FieldType.departure
                          ? 'Select Departure Airport'
                          : 'Select Destination Airport',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search by city or airport name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) =>
                      airportController.searchAirports(value, fieldType),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final searchActive = airportController.filteredAirports !=
                      (fieldType == FieldType.departure
                          ? airportController.defaultDepartureAirports
                          : airportController.defaultDestinationAirports);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        searchActive ? 'Search Results' : 'Suggested Airports',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (searchActive)
                        Text(
                          '${airportController.filteredAirports.length} results',
                          style: const TextStyle(color: TColors.grey),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    if (airportController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (airportController
                        .errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Text(
                          airportController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (airportController.filteredAirports.isEmpty) {
                      return const Center(
                        child: Text(
                          'No matching airports found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: airportController.filteredAirports.length,
                        itemBuilder: (context, index) {
                          final airport =
                          airportController.filteredAirports[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on,
                                color: TColors.primary),
                            title: Text(
                              '${airport.cityName} (${airport.code})',
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                            Text('${airport.name}, ${airport.countryName}'),
                            onTap: () {
                              controller.text =
                              '${airport.cityName} (${airport.code})';
                              if (onCitySelected != null) {
                                onCitySelected!(
                                    airport.cityName, airport.cityCode);
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Example of widget initialization and usage
class AirportSelectionScreen extends StatelessWidget {
  AirportSelectionScreen({super.key});

  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized first
    // You would typically do this in your app's initial binding
    if (!Get.isRegistered<AirportController>()) {
      Get.put(AirportController());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airport Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'Select Departure',
              icon: Icons.flight_takeoff,
              controller: departureController,
              fieldType: FieldType.departure,
              onCitySelected: (cityName, cityCode) {
                print('Selected departure: $cityName ($cityCode)');
                // Handle selection
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Select Destination',
              icon: Icons.flight_land,
              controller: destinationController,
              fieldType: FieldType.destination,
              onCitySelected: (cityName, cityCode) {
                print('Selected destination: $cityName ($cityCode)');
                // Handle selection
              },
            ),
          ],
        ),
      ),
    );
  }
}