import 'package:flight_bocking/home_search/home.dart';
import 'package:flight_bocking/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(height: 200, 'assets/img/thanku1.png'),
              const SizedBox(height: 20),

              // Icon/Image at the top
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColors.primary.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              // Thank You Text
              // Text(
              //   'Thank You!',
              //   style: TextStyle(
              //     fontSize: 28,
              //     fontWeight: FontWeight.bold,
              //     color: TColors.primary,
              //   ),
              // ),
              // SizedBox(height: 10),
              // Payment success or similar message
              const Text(
                'Your booking has been confirmed successfully.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Redirection message
              const Text(
                'You will be redirected to the home page shortly, or click below to return manually.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Home button
              ElevatedButton(
                onPressed: () {
                  Get.off(const HomeScreen());
                  // Navigator.pop(context); // Return to the previous or home page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(150, 50),
                ),
                child: const Text(
                  'Go Home',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
