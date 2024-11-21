import 'package:flutter/material.dart';

import '../widgets/colors.dart';

class DateSelectionField extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? minDate; // Minimum allowed date
  final double? fontSize; // Minimum allowed date
  final ValueChanged<DateTime>? onDateChanged; // Callback for date changes

  const DateSelectionField({
    super.key,
    required this.initialDate,
    this.minDate,
    this.fontSize=16,
    this.onDateChanged,
  });

  @override
  _DateSelectionFieldState createState() => _DateSelectionFieldState();
}

class _DateSelectionFieldState extends State<DateSelectionField> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate; // Initialize field with the initial date
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget.minDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(picked);
        }
      });
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
              style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}