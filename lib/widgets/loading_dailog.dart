import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/colors.dart';

class LoadingDialog extends StatefulWidget {
  final String message;

  const LoadingDialog({
    Key? key,
    this.message = 'Searching for the best hotels for you...',
  }) : super(key: key);

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdown = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom animated loading indicator
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: 20),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/img/waiting.png', // Add a hotel or travel related icon
                  width: 60,
                  height: 60,
                ),
              ),
            ),

            // Loading message
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: TColors.primary,
              ),
            ),

            const SizedBox(height: 15),

            // Progress indicators
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_countdown / 20),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 10),

            // Countdown text
            Text(
              'Estimated time: $_countdown seconds',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // Tips or additional information
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: TColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'We\'re searching through thousands of hotels to find the best deals for you.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}