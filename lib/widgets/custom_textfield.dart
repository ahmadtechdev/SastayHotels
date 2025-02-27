import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final String? initialValue;
  final Function(String name, String code)? onCitySelected;
  final TextEditingController? controller;
  final FieldType fieldType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.initialValue,
    this.onCitySelected,
    this.controller,
    this.fieldType = FieldType.departure,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  List<AirportData> airports = [];
  List<AirportData> defaultAirports = [];
  bool isLoading = false;
  String errorMessage = '';

  // Define city codes for departure defaults
  final List<String> departureAirportCodes = [
    "KHI", "LHE", "ISB", "LYP", "PEW", "MUX", "SKT"
  ];

  // Define city codes for destination defaults
  final List<String> destinationAirportCodes = [
    "DXB", "JED", "MED", "LON", "CDG", "IST", "KUL", "GYD", "BKK"
  ];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _fetchAirports();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAirports() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(Uri.parse('https://agent1.pk/api.php?type=airports'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] is List) {
          final List<dynamic> airportsData = jsonData['data'];
          setState(() {
            airports = airportsData.map((item) => AirportData.fromJson(item)).toList();

            // Once we have all airports, filter for default lists
            _filterDefaultAirports();
          });
        } else {
          setState(() {
            errorMessage = 'Invalid data format';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load airports. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterDefaultAirports() {
    if (airports.isEmpty) return;

    // Get the appropriate airport code list based on field type
    final airportCodes = widget.fieldType == FieldType.departure
        ? departureAirportCodes
        : destinationAirportCodes;

    // Filter airports list to find matching airports by code
    defaultAirports = airports.where((airport) {
      // Match by airport code directly
      return airportCodes.contains(airport.code);
    }).toList();

    // If we couldn't find all airports, log a warning
    if (defaultAirports.length < airportCodes.length) {
      print('Warning: Could not find all default airports in API response.');
      print('Found ${defaultAirports.length} out of ${airportCodes.length}');
    }

    // Sort the default airports to match the order of the airport codes
    defaultAirports.sort((a, b) {
      final indexA = airportCodes.indexOf(a.code);
      final indexB = airportCodes.indexOf(b.code);

      // If a code isn't found (shouldn't happen), put it at the end
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;

      return indexA.compareTo(indexB);
    });

    // Force refresh UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAirportSuggestions(context),
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            prefixIcon: Icon(widget.icon, color: TColors.primary),
            hintText: widget.hintText,
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
    String searchQuery = '';
    // Initially show default airports or loading indicator
    List<AirportData> displayedAirports = defaultAirports;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Handle initial loading state
            Widget airportsList;

            if (isLoading) {
              airportsList = const Center(child: CircularProgressIndicator());
            } else if (errorMessage.isNotEmpty) {
              airportsList = Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
            } else if (searchQuery.isEmpty && defaultAirports.isEmpty) {
              airportsList = const Center(
                child: Text(
                  'Loading default airports...',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            } else if (searchQuery.isNotEmpty && displayedAirports.isEmpty) {
              airportsList = const Center(
                child: Text(
                  'No matching airports found',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            } else {
              airportsList = ListView.builder(
                itemCount: displayedAirports.length,
                itemBuilder: (context, index) {
                  final airport = displayedAirports[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: TColors.primary),
                    title: Text(
                      '${airport.cityName} (${airport.code})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${airport.name}, ${airport.countryName}'),
                    onTap: () {
                      // Display city name with code in parentheses
                      _controller.text = '${airport.cityName} (${airport.code})';

                      // Call the callback with both name and code
                      if (widget.onCitySelected != null) {
                        widget.onCitySelected!(airport.cityName, airport.cityCode);
                      }

                      Navigator.pop(context);
                    },
                  );
                },
              );
            }

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
                          widget.fieldType == FieldType.departure
                              ? 'Select Departure Airport'
                              : 'Select Destination Airport',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                          if (searchQuery.isEmpty) {
                            // Show default airports when search is empty
                            displayedAirports = defaultAirports;
                          } else {
                            // Filter all airports based on search query
                            displayedAirports = airports
                                .where((airport) =>
                            airport.cityName.toLowerCase().contains(searchQuery) ||
                                airport.name.toLowerCase().contains(searchQuery) ||
                                airport.code.toLowerCase().contains(searchQuery) ||
                                airport.countryName.toLowerCase().contains(searchQuery))
                                .toList();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searchQuery.isEmpty ? 'Suggested Airports' : 'Search Results',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (searchQuery.isNotEmpty)
                          Text(
                            '${displayedAirports.length} results',
                            style: const TextStyle(color: TColors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: airportsList),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset to default airports for next time
      if (mounted) {
        setState(() {});
      }
    });
  }
}