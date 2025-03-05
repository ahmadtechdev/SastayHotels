import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/filter_modal.dart';
import 'package:flight_bocking/views/flight/search_flights/search_flight_utils/widgets/flight_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../widgets/colors.dart';
import '../../form/travelers/traveler_controller.dart';
import '../booking_flight/booking_flight.dart';

class ReviewTripPage extends StatefulWidget {
  final bool isMulti; // Indicates if it's a multi-city trip
  final Flight flight; // Selected flight
  final Map<String, dynamic> pricingInformation; // Pricing information from API for the selected package

  const ReviewTripPage({
    super.key,
    required this.isMulti,
    required this.flight,
    required this.pricingInformation,
  });

  @override
  ReviewTripPageState createState() => ReviewTripPageState();
}

class ReviewTripPageState extends State<ReviewTripPage> {
  List<BoxShadow> _animatedShadow = [
    BoxShadow(
      color: TColors.primary.withOpacity(0.4),
      blurRadius: 5,
      spreadRadius: 8,
      offset: const Offset(0, 0),
    )
  ];
  late Timer _shadowTimer;

  // Get the travelers controller to access passenger counts
  final travelersController = Get.find<TravelersController>();

  // Variables to store calculated prices
  late double adultPrice;
  late double childPrice;
  late double infantPrice;
  late double totalPrice;
  late String currency;

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
    _calculatePrices();
  }

  void _calculatePrices() {
    // Extract pricing information from the API response
    print("ahmad -1");
    print(widget.pricingInformation);
    final passengerInfoList = widget.pricingInformation["fare"]['passengerInfoList'];
    print("ahmad");
    print(passengerInfoList);

    // Initialize prices
    adultPrice = 0.0;
    childPrice = 0.0;
    infantPrice = 0.0;
    totalPrice = 0.0;
    currency = 'PKR'; // Default currency

    // Calculate prices based on passenger type
    for (var passengerInfo in passengerInfoList) {
      final passengerType = passengerInfo['passengerInfo']['passengerType'];
      final passengerTotalFare = passengerInfo['passengerInfo']['passengerTotalFare'];
      final price = passengerTotalFare['totalFare'].toDouble();

      if (passengerType == 'ADT') {
        adultPrice = price;
      } else if (passengerType == 'CHN') {
        childPrice = price;
      } else if (passengerType == 'INF') {
        infantPrice = price;
      }

      // Update total price
      totalPrice += price;
    }

    // If total price is not available, use the totalFare from the pricingInformation
    if (totalPrice == 0.0) {
      final totalFare = widget.pricingInformation['fare']['totalFare'];
      totalPrice = totalFare['totalPrice'];
      currency = totalFare['currency'];
    }
  }

  void _startShadowAnimation() {
    _shadowTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() {
        _animatedShadow = _animatedShadow[0].offset.dy == 2
            ? [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 2,
            spreadRadius: 15,
            offset: const Offset(0, 0),
          )
        ]
            : [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          )
        ];
      });
    });
  }

  @override
  void dispose() {
    _shadowTimer.cancel();
    super.dispose();
  }

  // Format price to show with commas and fixed decimal places
  String _formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background2,
      appBar: AppBar(
        backgroundColor: TColors.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Review Trip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FlightCard(
              flight: widget.flight,
              showReturnFlight: widget.isMulti,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                'Booking Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _animatedShadow,
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show adult price if there are adults
                      if (travelersController.adultCount.value > 0)
                        _buildPriceRow(
                            'Adult Price x ${travelersController.adultCount.value}',
                            '$currency ${_formatPrice(adultPrice * travelersController.adultCount.value)}'
                        ),

                      // Show child price if there are children
                      if (travelersController.childrenCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                                'Child Price x ${travelersController.childrenCount.value}',
                                '$currency ${_formatPrice(childPrice * travelersController.childrenCount.value)}'
                            ),
                          ],
                        ),

                      // Show infant price if there are infants
                      if (travelersController.infantCount.value > 0)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildPriceRow(
                                'Infant Price x ${travelersController.infantCount.value}',
                                '$currency ${_formatPrice(infantPrice * travelersController.infantCount.value)}'
                            ),
                          ],
                        ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),

                      // Show total amount
                      _buildPriceRow(
                        'Total Amount',
                        '$currency ${_formatPrice(totalPrice)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Review Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: TColors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currency ${_formatPrice(totalPrice)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => BookingForm(flight: widget.flight));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: TColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(48),
                        ),
                      ),
                      child: const Text(
                        'Book',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : TColors.grey,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? TColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }
}
// const Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Sasta Refund',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           Text(
//                             'PKR 849',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: TColors.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Image.asset(
//                             "assets/img/refund2.png",
//                             height: 100,
//                             width: 100,
//                           ),
//                           const SizedBox(width: 8),
//                           const SizedBox(
//                             width: 180,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Enhance your booking experience with:',
//                                   style: TextStyle(
//                                       color: TColors.grey, fontSize: 11),
//                                   softWrap: true,
//                                   overflow: TextOverflow.visible,
//                                   maxLines: null,
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.check,
//                                         size: 14, color: TColors.primary),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Zero cancellation fees',
//                                       style: TextStyle(fontSize: 11),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.check,
//                                         size: 14, color: TColors.primary),
//                                     SizedBox(width: 8),
//                                     Text('Guaranteed refund',
//                                         style: TextStyle(fontSize: 11)),
//                                   ],
//                                 ),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Icon(Icons.check,
//                                         size: 14, color: TColors.primary),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       'Ensured flexibility for your trip',
//                                       style: TextStyle(fontSize: 11),
//                                       softWrap: true,
//                                       overflow: TextOverflow.visible,
//                                       maxLines: null,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {},
//                           child: const Text(
//                             'Terms & Conditions',
//                             style:
//                                 TextStyle(color: TColors.primary, fontSize: 12),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: TColors.primary,
//                             foregroundColor: TColors.background,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(42),
//                             ),
//                           ),
//                           child: const Text('+ Add'),
//                         ),
//                       ),