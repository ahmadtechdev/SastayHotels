// Currency Dialog
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../flight_controller.dart';

class CurrencyDialog extends StatelessWidget {
  final FlightController controller;

  const CurrencyDialog({super.key, required this.controller});

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
