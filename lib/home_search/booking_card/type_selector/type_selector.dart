import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../widgets/colors.dart';

class TypeSelector extends StatefulWidget {
  final ValueChanged<String> onTypeChanged;

  const TypeSelector({super.key, required this.onTypeChanged});

  @override
  _TypeSelectorState createState() => _TypeSelectorState();
}

class _TypeSelectorState extends State<TypeSelector> {
  String selectedType = 'Flights';

  final List<Map<String, dynamic>> travelTypes = [
    {'icon': Icons.flight, 'label': 'Flights'},
    {'icon': MdiIcons.bed, 'label': 'Hotels'},
    {'icon': MdiIcons.earth, 'label': 'Tours'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: travelTypes.map((type) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedType = type['label'];
                widget.onTypeChanged(selectedType);
              });
            },
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