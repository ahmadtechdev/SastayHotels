import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../services/api_service_hotel.dart';
import '../../../../../widgets/colors.dart';
import '../../search_hotel_controller.dart';

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final int nights;
  final Function(dynamic) onSelect;
  final bool isSelected;

  const RoomCard({
    super.key,
    required this.room,
    required this.nights,
    required this.onSelect,
    required this.isSelected,
  });

  void _showCancellationPolicy(BuildContext context) async {
    final apiService = ApiServiceHotel();
    final controller = Get.find<SearchHotelController>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: TColors.primary),
      ),
    );

    try {
      final response = await apiService.getCancellationPolicy(
        sessionId: controller.sessionId.value,
        hotelCode: controller.hotelCode.value,
        groupCode: room['groupCode'] as int,
        currency: "USD",
        rateKeys: [room['rateKey']],
      );

      // Dismiss loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (response != null) {
        final rooms = response['rooms']?['room'] as List?;
        if (rooms?.isNotEmpty ?? false) {
          final roomData = rooms![0];
          final isCancellationAvailable =
              roomData['isCancelationPolicyAvailble'] ?? false;
          final policies = roomData['policies']?['policy'] as List?;

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.text,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: TColors.third,
                          ),
                          onPressed: () => Navigator.pop(context),
                          color: TColors.grey,
                        ),
                      ],
                    ),
                    const Divider(color: TColors.background3),
                    const SizedBox(height: 12),
                    if (!isCancellationAvailable)
                      const Text(
                        'Cancellation policy is not available for this room.',
                        style: TextStyle(color: TColors.grey),
                      )
                    else if (policies == null || policies.isEmpty)
                      const Text(
                        'No cancellation policy details available.',
                        style: TextStyle(color: TColors.grey),
                      )
                    else
                      ...policies.map((policy) {
                        final conditions = policy['condition'] as List?;
                        if (conditions == null || conditions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: conditions.map((condition) {
                            final fromDate =
                            DateTime.tryParse(condition['fromDate'] ?? '');
                            final toDate =
                            DateTime.tryParse(condition['toDate'] ?? '');
                            final percentage = condition['percentage'];
                            final timezone = condition['timezone'];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: TColors.background2,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: TColors.primary.withOpacity(0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TColors.primary.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date Range Section
                                    if (fromDate != null && toDate != null)
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: TColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_today,
                                              color: TColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Valid Period',
                                                  style: TextStyle(
                                                    color: TColors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${DateFormat('MMM dd, yyyy').format(fromDate)} - ${DateFormat('MMM dd, yyyy').format(toDate)}',
                                                  style: const TextStyle(
                                                    color: TColors.text,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                    if (fromDate != null)
                                      const SizedBox(height: 16),

                                    // Time Section
                                    if (condition['fromTime'] != null &&
                                        condition['toTime'] != null)
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: TColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.access_time,
                                              color: TColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Time Window',
                                                  style: TextStyle(
                                                    color: TColors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${condition['fromTime']} - ${condition['toTime']}',
                                                  style: const TextStyle(
                                                    color: TColors.text,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                    if (condition['fromTime'] != null)
                                      const SizedBox(height: 16),

                                    // Cancellation Amount Section
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: TColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.payments_outlined,
                                            color: TColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Refund Amount',
                                                style: TextStyle(
                                                  color: TColors.grey,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: percentage == '100'
                                                          ? Colors.green
                                                          .withOpacity(0.1)
                                                          : percentage == '0'
                                                          ? TColors.third
                                                          .withOpacity(
                                                          0.1)
                                                          : TColors.primary
                                                          .withOpacity(
                                                          0.1),
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4),
                                                    ),
                                                    child: Text(
                                                      '$percentage% Return',
                                                      style: TextStyle(
                                                        color: percentage ==
                                                            '100'
                                                            ? Colors.green
                                                            : percentage == '0'
                                                            ? TColors.third
                                                            : TColors
                                                            .primary,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (timezone != null) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.public,
                                            size: 16,
                                            color: TColors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Timezone: $timezone',
                                            style: const TextStyle(
                                              color: TColors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      print('Error showing cancellation policy: $e');
    }
  }

  void _showPriceBreakup(BuildContext context) async {
    final apiService = ApiServiceHotel();
    final controller = Get.find<SearchHotelController>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: TColors.primary),
      ),
    );

    try {
      final response = await apiService.getPriceBreakup(
        sessionId: controller.sessionId.value,
        hotelCode: controller.hotelCode.value,
        groupCode: room['groupCode'] as int,
        currency: "USD",
        rateKeys: [room['rateKey']],
      );

      // Dismiss loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      if (response != null) {
        final priceBreakdown = response['priceBreakdown'] as List?;
        if (priceBreakdown?.isNotEmpty ?? false) {
          final roomData = priceBreakdown![0];
          print(roomData['dateRange']);
          final dateRanges = roomData['dateRange'] != null
              ? List<Map<String, dynamic>>.from(roomData['dateRange'])
              : null;

          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price Breakup Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.text,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: TColors.third),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: TColors.background3),
                    if (dateRanges == null || dateRanges.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No price breakup details available for this room.',
                          style: TextStyle(color: TColors.grey),
                        ),
                      )
                    else
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Summary Section
                              Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: TColors.background2,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: TColors.primary.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _buildSummaryRow(
                                      'Gross Amount',
                                      roomData['grossAmount']?.toString() ??
                                          '0',
                                      Icons.monetization_on_outlined,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      'Tax',
                                      roomData['tax']?.toString() ?? '0',
                                      Icons.receipt_long_outlined,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSummaryRow(
                                      'Net Amount',
                                      roomData['netAmount']?.toString() ?? '0',
                                      Icons.account_balance_wallet_outlined,
                                    ),
                                  ],
                                ),
                              ),
                              // Daily Price Breakdown
                              ...dateRanges.map((dateRange) {
                                print(dateRanges);
                                final fromDate = DateTime.tryParse(
                                    dateRange['fromDate'] ?? '');
                                if (fromDate == null) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: TColors.background2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: TColors.primary.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: TColors.primary
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_today,
                                              color: TColors.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              DateFormat('MMM dd, yyyy')
                                                  .format(fromDate),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Price for this night',
                                            style: TextStyle(
                                              color: TColors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${dateRange['supplierText'] ?? '0'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: TColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      print('Error showing price breakup: $e');
    }
  }

// Add this helper method to the RoomCard class
  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: TColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: TColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          '\$$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: TColors.text,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricePerNight = room['price']['net'] ?? 0.0;
    final totalPrice = pricePerNight * nights;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildRoomIcon(),
                        const SizedBox(width: 8),
                        Text(
                          room['meal'] ?? 'Not Available',
                          style: const TextStyle(
                            color: TColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    _buildBadge(room['rateType'] ?? 'Unknown'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPriceSection(pricePerNight as double, totalPrice),
                if (room['remarks']?['remark'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    room['remarks']['remark'][0]['text'] ?? '',
                    style: const TextStyle(
                      color: TColors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                // Add Cancellation Policy Button
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showCancellationPolicy(context),
                        icon: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: TColors.primary,
                        ),
                        label: const Text(
                          'Cancellation Policy',
                          style: TextStyle(
                            color: TColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _showPriceBreakup(context),
                        icon: const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: TColors.primary,
                        ),
                        label: const Text(
                          'Price BreakUp',
                          style: TextStyle(
                            color: TColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onSelect(room),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isSelected ? Colors.green : TColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Select Room',
                      style: const TextStyle(
                        color: TColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double pricePerNight, double totalPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, size: 16, color: TColors.grey),
                SizedBox(width: 4),
                Text(
                  'Per Night',
                  style: TextStyle(
                    color: TColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${pricePerNight.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Row(
              children: [
                Icon(Icons.calculate, size: 16, color: TColors.grey),
                SizedBox(width: 4),
                Text(
                  'Total',
                  style: TextStyle(
                    color: TColors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: TColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.hotel,
        color: TColors.primary,
        size: 24,
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