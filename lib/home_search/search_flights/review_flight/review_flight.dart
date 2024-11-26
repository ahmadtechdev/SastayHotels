import 'package:flight_bocking/home_search/search_flights/booking_flight/booking_flight.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../widgets/colors.dart';

class ReviewTripPage extends StatefulWidget {
  const ReviewTripPage({Key? key}) : super(key: key);

  @override
  _ReviewTripPageState createState() => _ReviewTripPageState();
}

class _ReviewTripPageState extends State<ReviewTripPage> {
  final Color _animatedColor = TColors.primary;
  List<BoxShadow> _animatedShadow = [
    BoxShadow(
      color: TColors.primary.withOpacity(0.4),
      blurRadius: 5,
      spreadRadius: 8,
      offset: const Offset(0, 0),
    )
  ];
  late Timer _shadowTimer;

  @override
  void initState() {
    super.initState();
    _startShadowAnimation();
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
            // Flight Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Departing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.grey,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '07 Dec, 2024',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          "assets/img/logos/flyjinnah.png",
                          height: 30,
                          width: 40,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Serene Air',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ER-502 (I_SP)',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          '06:15 PM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward, color: TColors.grey),
                        Spacer(),
                        Text(
                          '08:00 PM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          'Karachi (KHI) - Nonstop - Islamabad (ISB)',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.shopping_bag, size: 16, color: TColors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Total: 80kg',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Serene Plus',
                      style: TextStyle(color: TColors.grey),
                    ),
                    const Divider(color: TColors.grey),
                    Row(
                      children: [
                        const Text(
                          'PKR 35,866',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text('Change'),
                        // ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(42),
                            border: Border.all(color: TColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical:0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Returning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.grey,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '07 Dec, 2024',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          "assets/img/logos/flyjinnah.png",
                          height: 30,
                          width: 40,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Serene Air',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ER-502 (I_SP)',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          '06:15 PM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward, color: TColors.grey),
                        Spacer(),
                        Text(
                          '08:00 PM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          'Karachi (KHI) - Nonstop - Islamabad (ISB)',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.shopping_bag, size: 16, color: TColors.grey),
                        SizedBox(width: 4),
                        Text(
                          'Total: 80kg',
                          style: TextStyle(color: TColors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Serene Plus',
                      style: TextStyle(color: TColors.grey),
                    ),
                    const Divider(color: TColors.grey),
                    Row(
                      children: [
                        const Text(
                          'PKR 35,866',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: const Text('Change'),
                        // ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(42),
                            border: Border.all(color: TColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Add-ons Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                'Add-Ons',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: TColors.background,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _animatedShadow,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sasta Refund',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'PKR 849',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/img/refund2.png",
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 180,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enhance your booking experience with:',
                                  style: TextStyle(
                                      color: TColors.grey, fontSize: 11),
                                  softWrap: true,
                                  // Ensures text wraps to the next line
                                  overflow: TextOverflow.visible,
                                  // Ensures overflow is handled visibly
                                  maxLines: null, // Allows unlimited lines
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.check,
                                        size: 14, color: TColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Zero cancellation fees', style: TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.check,
                                        size: 14, color: TColors.primary),
                                    SizedBox(width: 8),
                                    Text('Guaranteed refund',  style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.check,
                                        size: 14, color: TColors.primary),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ensured flexibility for your trip',
                                      style: TextStyle(fontSize: 11),
                                      softWrap: true,
                                      // Ensures text wraps to the next line
                                      overflow: TextOverflow.visible,
                                      // Ensures overflow is handled visibly
                                      maxLines: null, // Allows unlimited lines
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Terms & Conditions',
                            style: TextStyle(color: TColors.primary, fontSize: 12),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            foregroundColor: TColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(42),
                            ),
                          ),
                          child: const Text('+ Add'),
                        ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  children: [
                    Text(
                      'Review Details',
                      style: TextStyle(fontWeight: FontWeight.bold, color: TColors.grey),
                    ),
                   SizedBox(
                     height: 2,
                   ),
                    Text(
                      'PKR 35,866',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width:200,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(()=>const BookingForm());
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 2,
          )
        ],
      ) ,
    );
  }
}
