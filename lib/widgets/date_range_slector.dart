import 'package:flight_bocking/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDateRangeSelector extends StatelessWidget {
  final DateTimeRange dateRange;
  final Function(DateTimeRange) onDateRangeChanged;
  final int nights;
  final Function(int) onNightsChanged;

  const CustomDateRangeSelector({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.nights,
    required this.onNightsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row with Check-in and Nights Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Check-in Date Section
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final result = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: dateRange,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: TColors.primary,
                              onPrimary: TColors.background,
                              surface: TColors.background,
                              onSurface: TColors.text,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (result != null) {
                      onDateRangeChanged(result);
                    }
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: TColors.text),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start  ,
                      children: [
                        const Text(
                          'Check-in/Check-out',
                          style: TextStyle(
                            color: TColors.text,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                color: TColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year}- ${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}- $nights Nights',
                              style: const TextStyle(
                                color: TColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Nights Selector Section
              //   Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: TColors.background,
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: TColors.text),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         IconButton(
              //           icon: const Icon(Icons.remove,
              //               color: TColors.primary, size: 14),
              //           onPressed: () {
              //             if (nights > 1) onNightsChanged(nights - 1);
              //           },
              //           padding: EdgeInsets.zero,
              //           constraints: const BoxConstraints(),
              //         ),
              //         Text(
              //           '$nights Nights',
              //           style: const TextStyle(
              //             color: TColors.primary,
              //             fontSize: 12,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         IconButton(
              //           icon: const Icon(Icons.add,
              //               color: TColors.primary, size: 14),
              //           onPressed: () => onNightsChanged(nights + 1),
              //           padding: EdgeInsets.zero,
              //           constraints: const BoxConstraints(),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),

          // const SizedBox(height: 16),

          // // Check-out Date Display Section
          // Text(
          //   'Check-out: ${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}',
          //   style: const TextStyle(
          //     color: TColors.text,
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }
}