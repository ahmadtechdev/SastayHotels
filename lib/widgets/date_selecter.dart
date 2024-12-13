import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'colors.dart';

class DateSelector extends StatelessWidget {
  final double fontSize;
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final String label;

  DateSelector({
    super.key,
    required this.fontSize,
    required this.initialDate,
    required this.onDateChanged,
    this.label = "",
  });

  final Rx<DateTime> selectedDate =
      DateTime.now().obs; // Observable for managing state

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColors.primary,
              // Primary color for headers and selected date
              onPrimary: TColors.background,
              // Text color on primary color
              surface: TColors.background,
              // Background color for the date picker surface
              onSurface: TColors.text,
              // Text color for dates
              secondary:
                  TColors.secondary, // Color for the day selected by the user
            ),
            dialogBackgroundColor: TColors.background,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    TColors.third, // "Cancel" and "OK" button color
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked; // Update observable state
      onDateChanged(picked); // Notify parent of the date change
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedDate.value =
        initialDate; // Initialize with the provided initial date

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: TColors.background, // Background color
          border: Border.all(
            color: Colors.grey, // Border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              // Subtle shadow for depth
              blurRadius: 4,
              offset: const Offset(0, 2), // Shadow position
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: TColors.text,
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate.value),
                      style: TextStyle(
                        fontSize: fontSize,
                        color: TColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: fontSize,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
