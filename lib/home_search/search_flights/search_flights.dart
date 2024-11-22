import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/colors.dart';

// Models
class Flight {
  final String airline;
  final String flightNumber;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double price;
  final String from;
  final String to;
  final String type;

  Flight({
    required this.airline,
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.from,
    required this.to,
    required this.type,
  });
}

// Controller
class FlightController extends GetxController {
  var selectedCurrency = 'PKR'.obs;
  var selectedDate = DateTime.now().obs;
  var flights = <Flight>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyFlights();
  }

  void loadDummyFlights() {
    flights.value = [
      Flight(
        airline: 'Airblue',
        flightNumber: 'PA-401',
        departureTime: '09:00 AM',
        arrivalTime: '11:00 AM',
        duration: '2h',
        price: 50002,
        from: 'Lahore (LHE)',
        to: 'Karachi (KHI)',
        type: 'Value',
      ),
      Flight(
        airline: 'PIA',
        flightNumber: 'PK-302',
        departureTime: '08:00 AM',
        arrivalTime: '10:30 AM',
        duration: '2h 30m',
        price: 45000,
        from: 'Karachi (KHI)',
        to: 'Islamabad (ISB)',
        type: 'Economy',
      ),
      Flight(
        airline: 'SereneAir',
        flightNumber: 'ER-101',
        departureTime: '07:30 AM',
        arrivalTime: '09:45 AM',
        duration: '2h 15m',
        price: 48000,
        from: 'Islamabad (ISB)',
        to: 'Lahore (LHE)',
        type: 'Business',
      ),
      Flight(
        airline: 'Airblue',
        flightNumber: 'PA-402',
        departureTime: '01:00 PM',
        arrivalTime: '03:00 PM',
        duration: '2h',
        price: 52000,
        from: 'Karachi (KHI)',
        to: 'Lahore (LHE)',
        type: 'Premium',
      ),
      Flight(
        airline: 'PIA',
        flightNumber: 'PK-305',
        departureTime: '11:00 AM',
        arrivalTime: '01:00 PM',
        duration: '2h',
        price: 46000,
        from: 'Lahore (LHE)',
        to: 'Peshawar (PEW)',
        type: 'Economy',
      ),
      Flight(
        airline: 'SereneAir',
        flightNumber: 'ER-102',
        departureTime: '03:00 PM',
        arrivalTime: '05:15 PM',
        duration: '2h 15m',
        price: 49000,
        from: 'Peshawar (PEW)',
        to: 'Karachi (KHI)',
        type: 'Business',
      ),
      Flight(
        airline: 'Airblue',
        flightNumber: 'PA-403',
        departureTime: '06:00 AM',
        arrivalTime: '08:00 AM',
        duration: '2h',
        price: 53000,
        from: 'Multan (MUX)',
        to: 'Islamabad (ISB)',
        type: 'Value',
      ),
      Flight(
        airline: 'PIA',
        flightNumber: 'PK-308',
        departureTime: '09:30 AM',
        arrivalTime: '11:30 AM',
        duration: '2h',
        price: 47000,
        from: 'Karachi (KHI)',
        to: 'Multan (MUX)',
        type: 'Economy',
      ),
      Flight(
        airline: 'SereneAir',
        flightNumber: 'ER-103',
        departureTime: '10:00 AM',
        arrivalTime: '12:30 PM',
        duration: '2h 30m',
        price: 49500,
        from: 'Islamabad (ISB)',
        to: 'Peshawar (PEW)',
        type: 'Business',
      ),
      Flight(
        airline: 'Airblue',
        flightNumber: 'PA-404',
        departureTime: '05:00 PM',
        arrivalTime: '07:00 PM',
        duration: '2h',
        price: 54000,
        from: 'Lahore (LHE)',
        to: 'Karachi (KHI)',
        type: 'Premium',
      ),
    ];

  }

  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
    Get.back();
  }
}

// Currency Dialog
class CurrencyDialog extends StatelessWidget {
  final FlightController controller;

  const CurrencyDialog({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price Currency',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _currencyTile('PKR', '🇵🇰'),
            _currencyTile('AED', '🇦🇪'),
            _currencyTile('GBP', '🇬🇧'),
            _currencyTile('SAR', '🇸🇦'),
            _currencyTile('USD', '🇺🇸'),
          ],
        ),
      ),
    );
  }

  Widget _currencyTile(String currency, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(currency),
      onTap: () => controller.changeCurrency(currency),
    );
  }
}

// Flight Card
class FlightCard extends StatelessWidget {
  final Flight flight;

  const FlightCard({Key? key, required this.flight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: TColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.2),
            blurRadius: 10,
            // spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                    style: TextStyle(
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        flight.from,
                        style: TextStyle(
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
                        style: TextStyle(
                          color: TColors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.flight_takeoff),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalTime,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        flight.to,
                        style: TextStyle(
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
                    builder: (controller) => Text(
                      '${controller.selectedCurrency.value} ${flight.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Page
class FlightBookingPage extends StatelessWidget {
  final controller = Get.put(FlightController());

  FlightBookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lahore → Karachi',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '1 Dec',
              style: TextStyle(
                fontSize: 14,
                color: TColors.grey,
              ),
            ),
          ],
        ),
        actions: [
          GetX<FlightController>(
            builder: (controller) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CurrencyDialog(controller: controller),
                );
              },
              child: Text(
                controller.selectedCurrency.value,
                style: const TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: TColors.secondary,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _filterButton('Suggested', true),
                  _filterButton('Cheapest', false),
                  _filterButton('Fastest', false),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Row(
                      children: [
                        Icon(Icons.tune, size: 12,),
                        SizedBox(width: 4),
                        Text('Filters', style: TextStyle(fontSize: 12),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GetX<FlightController>(
              builder: (controller) => ListView.builder(
                itemCount: controller.flights.length,
                itemBuilder: (context, index) {
                  return FlightCard(flight: controller.flights[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String text, bool isSelected) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? TColors.primary : TColors.grey,
      ),
      child: Text(text, style: TextStyle(fontSize: 12),),
    );
  }
}
