import 'package:flutter/material.dart';

import '../../widgets/colors.dart';
import 'forms/flight_form.dart';
import 'forms/hotel_form.dart';

import 'type_selector/type_selector.dart';

class BookingCard extends StatefulWidget {
  const BookingCard({super.key});

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  String selectedType = 'Flights'; // Default type

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
              // Type Selector
              TypeSelector(
                onTypeChanged: (String type) {
                  setState(() {
                    selectedType = type;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Show the relevant form based on the selected type
              if (selectedType == 'Flights') const FlightForm(),
              if (selectedType == 'Hotels') const HotelForm(),
              if (selectedType == 'Tours')
                const Text('Tours functionality coming soon!'),
            ],
          ),
        ),
      ),
    );
  }
}
class CustomTextField extends StatelessWidget {

  final String hintText;
  final IconData icon;
  final String? initialValue; // Optional initial value
  final ValueChanged<String>? onChanged; // Callback for value changes

  const CustomTextField({
    super.key,

    required this.hintText,
    required this.icon,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialValue);

    return Row(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Re-enable spacing for better layout
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            // Trigger the callback whenever the text changes
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
      ],
    );
  }
}

class DateSelectionField extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateChanged; // Callback for date changes
  final String? hintText; // Optional placeholder

  const DateSelectionField({
    super.key,
    required this.initialDate,
    this.onDateChanged,
    this.hintText,
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
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      // Trigger the callback to inform the parent widget of the change
      if (widget.onDateChanged != null) {
        widget.onDateChanged!(picked);
      }
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
              selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : (widget.hintText ?? 'Select a date'), // Add hint text
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
