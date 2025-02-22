import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../widgets/colors.dart';
import '../../../form/controllers/flight_search_controller.dart';
import '../filter_modal.dart';
import '../flight_controller.dart';

class FlightCard extends StatefulWidget {
  final Flight flight;
  final bool showReturnFlight;

  const FlightCard({
    super.key,
    required this.flight,
    this.showReturnFlight = true,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calculate total layover time

// Add this utility function to translate cabin codes
  String getCabinClassName(String cabinCode) {
    switch (cabinCode) {
      case 'F':
        return 'First Class';
      case 'C':
        return 'Business Class';
      case 'Y':
        return 'Economy Class';
      case 'W':
        return 'Premium Economy';
      default:
        return 'Economy Class';
    }
  }

// Add this utility function for meal codes
  String getMealInfo(String mealCode) {
    switch (mealCode.toUpperCase()) {
      case 'P':
        return 'Alcoholic beverages for purchase';
      case 'C':
        return 'Complimentary alcoholic beverages';
      case 'B':
        return 'Breakfast';
      case 'K':
        return 'Continental breakfast';
      case 'D':
        return 'Dinner';
      case 'F':
        return 'Food for purchase';
      case 'G':
        return 'Food/Beverages for purchase';
      case 'M':
        return 'Meal';
      case 'N':
        return 'No meal service';
      case 'R':
        return 'Complimentary refreshments';
      case 'V':
        return 'Refreshments for purchase';
      case 'S':
        return 'Snack';
      default:
        return 'No Meal';
    }
  }

  // Format baggage information
  String formatBaggageInfo() {
    // print("baggage check");
    // print(widget.flight.baggageAllowance.pieces );
    // print(widget.flight.baggageAllowance.weight );
    if (widget.flight.baggageAllowance.pieces > 0) {
      return '${widget.flight.baggageAllowance.pieces} piece(s) included';
    } else if (widget.flight.baggageAllowance.weight > 0) {
      return '${widget.flight.baggageAllowance.weight} ${widget.flight.baggageAllowance.unit} included';
    }
    return widget.flight.baggageAllowance.type;
  }

  // Add these utility methods for date formatting
  String formatTimeFromDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('E, d MMM yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    print("stop schedules");
    print(widget.flight.departureTime);
    print(widget.flight.arrivalTime);
    final searchConroller = Get.put(FlightSearchController());
    String formatTime(String time) {
      if (time.isEmpty) return 'N/A';
      return time.split(':').sublist(0, 2).join(':'); // Extract HH:mm
    }

    // Update these methods to handle the new DateTime format
    String getDepartureTime() {
      final stop = widget.flight.stopSchedules.firstWhere(
        (schedule) =>
            schedule['departure']['city'] == searchConroller.origins.first,
        orElse: () => {},
      );
      return stop.isNotEmpty
          ? formatTimeFromDateTime(stop['departure']['dateTime'])
          : 'N/A';
    }

    String getArrivalTime() {
      final stop = widget.flight.stopSchedules.firstWhere(
        (schedule) =>
            schedule['arrival']['city'] == searchConroller.destinations.first,
        orElse: () => {},
      );
      return stop.isNotEmpty
          ? formatTimeFromDateTime(stop['arrival']['dateTime'])
          : 'N/A';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Flight Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SingleChildScrollView(
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Text(
                //             // widget.flight.departureTime,
                //             getDepartureTime(),
                //             style: const TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //           Text(
                //             // widget.flight.from,
                //             searchConroller.origins.first,
                //             style: const TextStyle(
                //               color: TColors.grey,
                //               fontSize: 16,
                //             ),
                //           ),
                //         ],
                //       ),
                //       Column(
                //         children: [
                //           Text(
                //             widget.flight.duration,
                //             style: const TextStyle(
                //               color: TColors.grey,
                //               fontSize: 14,
                //             ),
                //           ),
                //           // const Icon(
                //           //   Icons.flight,
                //           //   color: TColors.primary,
                //           // ),
                //           Stack(
                //             alignment: Alignment.center,
                //             children: [
                //               Container(
                //                 height: 2,
                //                 width: 70,
                //                 color: Colors.grey[300],
                //               ),
                //               const Icon(
                //                 Icons.flight,
                //                 size: 20,
                //                 color: TColors.primary,
                //               ),
                //             ],
                //           ),
                //           if (widget.flight.isNonStop)
                //             const Text(
                //               'Nonstop',
                //               style: TextStyle(
                //                 fontSize: 14,
                //                 color: TColors.grey,
                //               ),
                //             )
                //           else
                //             Text(
                //               '${widget.flight.stops.toSet().length} ${widget.flight.stops.toSet().length == 1 ? 'stop' : 'stops'}',
                //               style: const TextStyle(
                //                 fontSize: 14,
                //                 color: TColors.grey,
                //               ),
                //             ),
                //           if (widget.flight.stops.isNotEmpty)
                //             Text(
                //               widget.flight.stops
                //                   .toSet()
                //                   .where((stop) =>
                //                       stop != searchConroller.origins &&
                //                       stop !=
                //                           searchConroller.destinations)
                //                   .toList()
                //                   .join(', '),
                //               style: const TextStyle(
                //                 fontSize: 12,
                //                 color: TColors.grey,
                //               ),
                //             ),
                //         ],
                //       ),
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: [
                //           Text(
                //             // widget.flight.arrivalTime,
                //             getArrivalTime(),
                //             style: const TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //           Text(
                //             // widget.flight.to,
                //             searchConroller.destinations.first,
                //             style: const TextStyle(
                //               color: TColors.grey,
                //               fontSize: 16,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                for (var legSchedule in widget.flight.legSchedules)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              widget.flight.imgPath,
                              height: 32,
                              width: 50,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.flight.airline,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // const SizedBox(width: 8),
                            // Text(
                            //   widget.flight.flightNumber,
                            //   style: const TextStyle(
                            //     color: TColors.grey,
                            //     fontSize: 14,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatTime(legSchedule['departure']['time']
                                        .toString()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${legSchedule['departure']['city']} (${legSchedule['departure']['airport']})',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${legSchedule['elapsedTime'] ~/ 60}h ${legSchedule['elapsedTime'] % 60}m',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 2,
                                        width: 70,
                                        color: Colors.grey[300],
                                      ),
                                      const Icon(
                                        Icons.flight,
                                        size: 20,
                                        color: TColors.primary,
                                      ),
                                    ],
                                  ),
                                  if (legSchedule['stops'].isEmpty)
                                    const Text(
                                      'Nonstop',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TColors.grey,
                                      ),
                                    )
                                  else
                                    Text(
                                      '${legSchedule['stops'].length} ${legSchedule['stops'].length == 1 ? 'stop' : 'stops'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: TColors.grey,
                                      ),
                                    ),
                                  if (legSchedule['stops'].isNotEmpty)
                                    Text(
                                      legSchedule['stops'].join(', '),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: TColors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatTime(legSchedule['arrival']['time']
                                        .toString()),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${legSchedule['arrival']['city']} (${legSchedule['arrival']['airport']})',
                                    style: const TextStyle(
                                      color: TColors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GetX<FlightController>(
                      builder: (controller) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: TColors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(42),
                          border:
                              Border.all(color: TColors.black.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${controller.selectedCurrency.value} ${widget.flight.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Details Section
          // Expanded Details Section
          // Expandable Details Section
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                if (isExpanded) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Flight Details',
                        style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: TColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flight Segments
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.flight.stopSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = widget.flight.stopSchedules[index];
                      return _buildFlightSegment(
                        schedule,
                        index,
                        widget.flight.stopSchedules.length,
                      );
                    },
                  ),

                  // Baggage Information
                  _buildSectionCard(
                    title: 'Baggage Allowance',
                    content: formatBaggageInfo(),
                    icon: Icons.luggage,
                  ),

                  // Fare Rules
                  _buildSectionCard(
                    title: 'Policy',
                    content: _buildFareRules(),
                    icon: Icons.rule,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSegment(
      Map<String, dynamic> schedule, int index, int totalSegments) {
    // Get flight number and carrier from the schedule
    final carrier = schedule['carrier'] ?? {};
    final flightNumber =
        '${carrier['marketing'] ?? 'XX'}-${carrier['marketingFlightNumber'] ?? '000'}';
    final marketingCarrier = carrier['marketing'] ?? 'Unknown';
    final airlineInfo = getAirlineInfo(marketingCarrier);
    FlightSegmentInfo? segmentInfo;
    if (index < widget.flight.segmentInfo.length) {
      segmentInfo = widget.flight.segmentInfo[index];
    }

    print(segmentInfo);

    // Calculate layover time for segments within the same leg
    String? layoverTime;

    // Update the departure and arrival time display
    final departureDateTime = schedule['departure']['dateTime'];
    final arrivalDateTime = schedule['arrival']['dateTime'];

    // Find which leg this schedule belongs to
    for (var legSchedule in widget.flight.legSchedules) {
      final schedules = legSchedule['schedules'] as List;
      final currentScheduleIndex = schedules.indexWhere((s) =>
          s['departure']['time'] == schedule['departure']['time'] &&
          s['arrival']['time'] == schedule['arrival']['time']);

      // If found and not the last schedule in this leg
      if (currentScheduleIndex != -1 &&
          currentScheduleIndex < schedules.length - 1) {
        // Get arrival time of current flight
        final currentArrivalTime = schedule['arrival']['time'].toString();

        // Get departure time of next flight in the same leg
        final nextSchedule = schedules[currentScheduleIndex + 1];
        final nextDepartureTime = nextSchedule['departure']['time'].toString();

        // Parse times with a fixed date to handle day changes
        final arrival = DateTime.parse("2024-01-01T$currentArrivalTime");
        DateTime departure = DateTime.parse("2024-01-01T$nextDepartureTime");

        // If departure is before arrival, it means it's next day
        if (departure.isBefore(arrival)) {
          departure = departure.add(const Duration(days: 1));
        }

        // Calculate difference in minutes
        final difference = departure.difference(arrival);
        final totalMinutes = difference.inMinutes;

        if (totalMinutes > 0) {
          final hours = totalMinutes ~/ 60;
          final minutes = totalMinutes % 60;
          layoverTime = '${hours}h ${minutes}m';
        }
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: index < totalSegments - 1
                ? Colors.grey[300]!
                : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flight number and carrier info
          Row(
            children: [
              Image.asset(
                airlineInfo.logoPath,
                height: 24,
                width: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${airlineInfo.name} $flightNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cabin Class information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              getCabinClassName(segmentInfo?.cabinCode ?? 'Y'),
              style: const TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.flight_takeoff,
                  size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(
                'Flight Segment ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['departure']['city'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['departure']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(departureDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(departureDateTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.flight, color: TColors.primary),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.restaurant_menu,
                            size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          getMealInfo(segmentInfo?.mealCode ?? 'N'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      schedule['arrival']['city'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['arrival']['terminal'] ?? "Main"}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      formatTimeFromDateTime(arrivalDateTime),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      formatFullDateTime(arrivalDateTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show layover time if it exists
          if (layoverTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Layover: $layoverTime',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _buildFareRules() {
    return '''
• ${widget.flight.isRefundable ? 'Refundable' : 'Non-refundable'} ticket
• Date change permitted with fee
• Standard meal included
• Free seat selection
• Cabin baggage allowed
• Check-in baggage as per policy''';
  }
}
