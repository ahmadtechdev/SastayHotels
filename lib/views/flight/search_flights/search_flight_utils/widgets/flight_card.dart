import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../widgets/colors.dart';
import '../filter_modal.dart';
import '../flight_controller.dart';

class FlightCard extends StatefulWidget {
  final Flight flight;

  const FlightCard({super.key, required this.flight});

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> with SingleTickerProviderStateMixin {
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
  String calculateTotalLayoverTime() {
    int totalLayoverMinutes = 0;

    // Get total leg elapsed time from legDesc
    int totalLegTime = widget.flight.legElapsedTime ?? 0;

    // Sum up all individual flight times
    int totalFlightTime = 0;
    for (var schedule in widget.flight.stopSchedules) {
      totalFlightTime += schedule['elapsedTime'] as int? ?? 0;
    }

    // Layover time is the difference
    totalLayoverMinutes = totalLegTime - totalFlightTime;

    if (totalLayoverMinutes <= 0) return 'N/A';

    final hours = totalLayoverMinutes ~/ 60;
    final minutes = totalLayoverMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // Get meal information for a specific schedule
  String getMealInfo(Map<String, dynamic> schedule) {
    final mealCode = schedule['mealService'] as String? ?? 'Standard';
    switch (mealCode.toUpperCase()) {
      case 'B':
        return 'Breakfast';
      case 'L':
        return 'Lunch';
      case 'D':
        return 'Dinner';
      case 'S':
        return 'Snack';
      default:
        return 'Standard Meal';
    }
  }

  // Format baggage information
  String formatBaggageInfo() {
    if (widget.flight.baggageAllowance.pieces > 0) {
      return '${widget.flight.baggageAllowance.pieces} piece(s) - ${widget.flight.baggageAllowance.type}';
    }
    return 'Check airline policy';
  }

  @override
  Widget build(BuildContext context) {
    return  AnimatedContainer(
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
                    const SizedBox(width: 8),
                    Text(
                      widget.flight.flightNumber,
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.flight.departureTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.flight.from,
                          style: const TextStyle(
                            color: TColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          widget.flight.duration,
                          style: const TextStyle(
                            color: TColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        // const Icon(
                        //   Icons.flight,
                        //   color: TColors.primary,
                        // ),
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
                              color:TColors.primary,
                            ),
                          ],
                        ),
                        if (widget.flight.isNonStop)
                          const Text(
                            'Nonstop',
                            style: TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          )
                        else
                          Text(
                            '${widget.flight.stops.length} ${widget.flight.stops.length == 1 ? 'stop' : 'stops'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: TColors.grey,
                            ),
                          ),
                        if (widget.flight.stops.isNotEmpty)
                          Text(
                            'via ${widget.flight.stops.join(', ')}',
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
                          widget.flight.arrivalTime,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.flight.to,
                          style: const TextStyle(
                            color: TColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // TextButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       isExpanded = !isExpanded;
                    //     });
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         isExpanded ? 'Hide Details' : 'Show Details',
                    //         style: const TextStyle(
                    //           color: TColors.primary,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //       Icon(
                    //         isExpanded ? Icons.expand_less : Icons.expand_more,
                    //         color: TColors.primary,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    GetX<FlightController>(
                      builder: (controller) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: TColors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(42),
                          border: Border.all(color: TColors.black.withOpacity(0.3)),
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
                      Text(
                        'Flight Details',
                        style: TextStyle(
                          color: TColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
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
                    title: 'Fare Rules',
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

  Widget _buildFlightSegment(Map<String, dynamic> schedule, int index, int totalSegments) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: index < totalSegments - 1 ? Colors.grey[300]! : Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight_takeoff, size: 16, color: TColors.primary),
              SizedBox(width: 8),
              Text(
                'Flight Segment ${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule['departure']['city'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['departure']['terminal'] ?? "Main"}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      schedule['departure']['time'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.flight, color: TColors.primary),
                  Text(
                    getMealInfo(schedule),
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      schedule['arrival']['city'],
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Terminal ${schedule['arrival']['terminal'] ?? "Main"}',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      schedule['arrival']['time'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
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
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: TColors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicy(String title, String description, String fee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: TColors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fee: $fee',
            style: const TextStyle(
              color: TColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopDetail(Map<String, dynamic> stop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stop['arrival']['city']} (${stop['arrival']['airport']})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arrival: ${stop['arrival']['time']}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Terminal: ${stop['arrival']['terminal'] ?? 'Main'}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Departure: ${stop['departure']['time']}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Terminal: ${stop['departure']['terminal'] ?? 'Main'}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
