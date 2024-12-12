import 'package:flutter/material.dart';

import '../../../../../widgets/colors.dart';

class TripTypeSelector extends StatefulWidget {
  final ValueChanged<String> onTripTypeChanged;

  const TripTypeSelector({super.key, required this.onTripTypeChanged});

  @override
  TripTypeSelectorState createState() => TripTypeSelectorState();
}

class TripTypeSelectorState extends State<TripTypeSelector> {
  String selectedTripType = 'One-way'; // Default trip type

  @override
  Widget build(BuildContext context) {
    final tripTypes = ['One-way', 'Return', 'Multi City'];

    return Row(
      children: tripTypes.map((type) {

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTripType = type;
            });
            widget.onTripTypeChanged(type);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: selectedTripType == type ? TColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedTripType == type
                    ? TColors.primary
                    : TColors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              type,
              style: TextStyle(
                color: selectedTripType == type ? Colors.white : TColors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
