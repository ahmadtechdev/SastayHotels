import 'package:flutter/material.dart';

import '../widgets/colors.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 40),
      child: Container(

        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Travel type selection
              const TravelTypeSelector(),
              const SizedBox(height: 16),
              // Journey type selection
              const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: TripTypeSelector()),
              const SizedBox(height: 16),
              // City selection fields
              const CustomTextField(
                label: 'From',
                hintText: 'Enter departure city',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 8),
              const CustomTextField(
                label: 'To',
                hintText: 'Enter destination city',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              // Date selection field
              DateSelectionField(
                initialDate: DateTime(2024, 11, 29),
              ),
              const SizedBox(height: 16),
              // Travelers field
              const TravelersField(initialAdultCount: 1, initialChildrenCount: 1, initialInfantCount: 1, initialClass: 'Economy',          ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Trigger search
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text(
                  'Search Flights',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // const SizedBox(height: 8),
        TextField(
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
      ],
    );
  }
}

class TripTypeSelector extends StatefulWidget {
  const TripTypeSelector({super.key});

  @override
  _TripTypeSelectorState createState() => _TripTypeSelectorState();
}

class _TripTypeSelectorState extends State<TripTypeSelector> {
  String selectedType = 'One Way';

  final tripTypes = ['One Way', 'Return', 'Multi City'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tripTypes.map((type) {
        return GestureDetector(
          onTap: () => setState(() => selectedType = type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: selectedType == type ? TColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedType == type
                    ? TColors.primary
                    : TColors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: selectedType == type ? Colors.white : TColors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TravelTypeSelector extends StatefulWidget {
  const TravelTypeSelector({super.key});

  @override
  _TravelTypeSelectorState createState() => _TravelTypeSelectorState();
}

class _TravelTypeSelectorState extends State<TravelTypeSelector> {
  String selectedType = 'Flights';

  final List<Map<String, dynamic>> travelTypes = [
    {'icon': Icons.flight, 'label': 'Flights'},
    {'icon': Icons.directions_bus, 'label': 'Buses'},
    {'icon': Icons.card_travel, 'label': 'Visa'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: travelTypes.map((type) {
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedType = type['label']),
            child: Column(
              children: [
                Icon(
                  type['icon'],
                  color: selectedType == type['label']
                      ? TColors.primary
                      : TColors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  type['label'],
                  style: TextStyle(
                    color: selectedType == type['label']
                        ? TColors.primary
                        : TColors.grey,
                    fontWeight: selectedType == type['label']
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
class DateSelectionField extends StatefulWidget {
  final DateTime initialDate;

  const DateSelectionField({
    super.key,
    required this.initialDate,
  });

  @override
  _DateSelectionFieldState createState() => _DateSelectionFieldState();
}

class _DateSelectionFieldState extends State<DateSelectionField> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: TColors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: TColors.primary),
            const SizedBox(width: 12),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}


class TravelersField extends StatefulWidget {
  final int initialAdultCount;
  final int initialChildrenCount;
  final int initialInfantCount;
  final String initialClass;

  const TravelersField({
    super.key,
    required this.initialAdultCount,
    required this.initialChildrenCount,
    required this.initialInfantCount,
    required this.initialClass,
  });

  @override
  _TravelersFieldState createState() => _TravelersFieldState();
}

class _TravelersFieldState extends State<TravelersField> {
  late int adultCount;
  late int childrenCount;
  late int infantCount;
  late String travelClass;

  @override
  void initState() {
    super.initState();
    adultCount = widget.initialAdultCount;
    childrenCount = widget.initialChildrenCount;
    infantCount = widget.initialInfantCount;
    travelClass = widget.initialClass;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTravelersDialog(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: TColors.primary),
              const SizedBox(width: 12),
              Text(
                  '$adultCount Adults, $childrenCount Children, $infantCount Infants, $travelClass'),
            ],
          ),
        ),
      ),
    );
  }

  void _showTravelersDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,  // Ensure the bottom sheet adapts to content size
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.9,  // Take up 90% of the screen height to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView( // Makes the content scrollable
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTravelerRow('Adult', adultCount, (newValue) {
                    setState(() {
                      adultCount = newValue;
                      if (infantCount > adultCount) {
                        infantCount = adultCount; // Ensure infants ≤ adults
                      }
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildTravelerRow('Children', childrenCount, (newValue) {
                    setState(() {
                      childrenCount = newValue;
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildTravelerRow('Infants', infantCount, (newValue) {
                    setState(() {
                      if (newValue <= adultCount) {
                        infantCount = newValue; // Infants cannot exceed adults
                      }
                    });
                  }, isInfant: true),
                  const SizedBox(height: 24),
                  const Text('Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildClassSelection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTravelerRow(String label, int count, ValueChanged<int> onChange,
      {bool isInfant = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isInfant ? Icons.child_care : Icons.person),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              isInfant ? '7 days to 23 months' : '12 years or above',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: count > 0
                  ? () => onChange(count - 1)
                  : null, // Decrease count
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$count'),
            IconButton(
              onPressed: () => onChange(count + 1), // Increase count
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassSelection() {
    return Column(
      children: [
        _buildClassRadio('Economy'),
        _buildClassRadio('Premium Economy'),
        _buildClassRadio('Business'),
        _buildClassRadio('First'),
      ],
    );
  }

  Widget _buildClassRadio(String className) {
    return RadioListTile<String>(
      title: Text(className),
      value: className,
      groupValue: travelClass,
      onChanged: (value) {
        setState(() {
          travelClass = value!;
        });
      },
    );
  }
}