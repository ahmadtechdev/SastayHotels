import 'package:flutter/material.dart';

import '../../../../../widgets/colors.dart';

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final int nights;
  final Function(dynamic) onSelect;
  final bool isSelected;
  final bool showBookNowButton;
  final bool isLoading; // Add this new parameter

  const RoomCard({
    super.key,
    required this.room,
    required this.nights,
    required this.onSelect,
    required this.isSelected,
    this.showBookNowButton = false,
    this.isLoading = false, // Default to false
  });

  List<Map<String, dynamic>> _getCancellationPolicies() {
    final rates = room['rates'] as List?;
    if (rates == null || rates.isEmpty) return [];

    final firstRate = rates.first as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(
        firstRate['cancellationPolicies'] ?? []);
  }

  String _getRateType() {
    final rates = room['rates'] as List?;
    if (rates == null || rates.isEmpty) return 'N/A';

    final firstRate = rates.first as Map<String, dynamic>;
    return firstRate['rateType']?.toString() ?? 'N/A';
  }

  String _getMealPlan() {
    final rates = room['rates'] as List?;
    if (rates == null || rates.isEmpty) return 'No meal included';

    final firstRate = rates.first as Map<String, dynamic>;
    return firstRate['meal']?.toString() ?? 'No meal included';
  }

  double _getTotalPrice() {
    final rates = room['rates'] as List?;
    if (rates == null || rates.isEmpty) return 0.0;

    final firstRate = rates.first as Map<String, dynamic>;
    final price = firstRate['price']?['net'];
    return (price is num) ? price.toDouble() : 0.0;
  }

  double _getPricePerNight() {
    final totalPrice = _getTotalPrice();
    return nights > 0 ? totalPrice / nights : totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    _getPricePerNight();
    _getTotalPrice();
    final cancellationPolicies = _getCancellationPolicies();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? TColors.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? TColors.primary.withOpacity(0.05) : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room Type Header
                Text(
                  room['roomName']?.toString() ?? 'Standard Room',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TColors.text,
                  ),
                ),
                const SizedBox(height: 12),

                // Meal Plan Section
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu,
                        color: TColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getMealPlan(),
                      style: const TextStyle(
                        color: TColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ), 
                const SizedBox(height: 8),

                // Rate Type Badge
                // _buildBadge(_getRateType()),
                // const SizedBox(height: 16),

                // Price Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price per night',
                          style: TextStyle(
                            color: TColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'PKR ${(_getPricePerNight() * 278.5).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: TColors.text,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$nights nights total',
                          style: const TextStyle(
                            color: TColors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'PKR ${(_getTotalPrice() * 278.5).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: TColors.text,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cancellation Policy
                if (cancellationPolicies.isNotEmpty) ...[
                  const Text(
                    'Cancellation Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...cancellationPolicies.map((policy) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${policy['text'] ?? 'No cancellation policy available'}',
                          style: const TextStyle(
                            color: TColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                // Button - Either "Select Room" or "Book Now" depending on the flag
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width:
                            double.infinity, // Make button container full width
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => onSelect(room),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: showBookNowButton
                                ? Colors.green
                                : (isSelected ? Colors.green : TColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            showBookNowButton
                                ? (isLoading
                                    ? 'Checking Availability...'
                                    : 'Book Now')
                                : (isSelected ? 'Selected' : 'Select Room'),
                            style: const TextStyle(
                              color: TColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: TColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    final isRefundable = text.toLowerCase() == 'refundable';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRefundable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isRefundable ? Colors.green.shade700 : Colors.red.shade700,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
