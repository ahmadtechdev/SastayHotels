// Flight Card
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../widgets/colors.dart';

import '../filter_modal.dart';
import '../flight_controller.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  flight.imgPath,
                  height: 32,
                  width: 50,
                ),
                const SizedBox(width: 8),
                Text(
                  flight.airline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  flight.flightNumber,
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
                      flight.departureTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      flight.from,
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
                      flight.duration,
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.flight_takeoff,
                      color: TColors.primary,
                    ),
                    if (flight.isNonStop)
                      const Text(
                        'Nonstop',
                        style: TextStyle(
                          fontSize: 14,
                          color: TColors.grey,
                        ),
                      )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.arrivalTime,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      flight.to,
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
                      '${controller.selectedCurrency.value} ${flight.price.toStringAsFixed(2)}',
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

            // Add to FlightCard
            if (flight.departureTerminal.isNotEmpty)
              Text('Terminal: ${flight.departureTerminal}'),
            if (flight.baggageAllowance.pieces > 0)
              Text('Baggage: ${flight.baggageAllowance.pieces} pieces'),
          ],
        ),
      ),
    );
  }
}
