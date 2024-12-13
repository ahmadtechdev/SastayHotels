import 'package:flutter/material.dart';
import 'colors.dart';

class DateSelectionField extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String? hintText;
  final double? fontSize;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? minDate;

  const DateSelectionField({
    super.key,
    required this.initialDate,
    this.onDateChanged,
    this.hintText,
    this.fontSize = 16,
    this.firstDate,
    this.lastDate,
    this.minDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(minDate ?? currentDate)
          ? minDate ?? currentDate
          : initialDate,
      firstDate: minDate ?? firstDate ?? currentDate,
      lastDate: lastDate ?? DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        // Disable dates before minDate if specified
        if (minDate != null) {
          return date.isAfter(minDate!.subtract(const Duration(days: 1)));
        }
        return true;
      },
    );

    if (picked != null && picked != initialDate) {
      onDateChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: TColors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: TColors.primary),
            const SizedBox(width: 12),
            Text(
              '${initialDate.day}/${initialDate.month}/${initialDate.year}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
