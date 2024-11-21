import 'package:flutter/material.dart';

import 'colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final String? initialValue; // Optional initial value
  final ValueChanged<String>? onChanged; // Callback for value changes
  final TextEditingController? controller; // Controller for the text field

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.initialValue,
    this.onChanged,
    this.controller, // Allow an external controller to be passed
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // If no controller is provided, create a local one
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // Dispose the local controller only if it's not provided externally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCitySuggestions(context),
      child: AbsorbPointer(
        // Prevents focus on TextField so that we can use onTap to show the popup
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

  void _showCitySuggestions(BuildContext context) {
    List<Map<String, String>> cities = [
      {'name': 'Dubai', 'details': 'City: Dubai, United Arab Emirates'},
      {'name': 'Mecca, Makkah', 'details': 'City: Mecca, Makkah, Saudi Arabia'},
      {'name': 'Medina', 'details': 'City: Medina, Saudi Arabia'},
      {'name': 'Istanbul', 'details': 'City: Istanbul, Turkey'},
      {'name': 'New York', 'details': 'City: New York, United States'},
      {'name': 'London', 'details': 'City: London, United Kingdom'},
      {'name': 'Antalya', 'details': 'City: Antalya, Turkey'},
      {'name': 'Kuala Lumpur', 'details': 'City: Kuala Lumpur, Malaysia'},
      {'name': 'Bangkok', 'details': 'City: Bangkok, Thailand'},
    ];

    String searchQuery = '';
    List<Map<String, String>> filteredCities = List.from(cities);

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
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Destination',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          hintText: 'Enter City Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                            filteredCities = cities
                                .where((city) =>
                                city['name']!.toLowerCase().contains(searchQuery))
                                .toList();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Top Destinations',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      filteredCities.isNotEmpty
                          ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on,
                                color: TColors.primary),
                            title: Text(
                              city['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(city['details']!),
                            onTap: () {
                              // Update the controller text with the selected city
                              _controller.text = city['name']!;
                              Navigator.pop(context);
                              if (widget.onChanged != null) {
                                widget.onChanged!(city['name']!);
                              }
                            },
                          );
                        },
                      )
                          : const Center(
                        child: Text(
                          'No cities found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}