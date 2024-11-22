import 'package:flutter/material.dart';

import 'colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double logoHeight; // Height of the logo

  const CustomAppBar({
    super.key,
    this.logoHeight = 35.0, // Default logo height
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Image.asset(
        "assets/img/newLogo.png",
        height: logoHeight,
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: const Row(
            children: [
              Icon(Icons.headset_mic_outlined, color: TColors.primary),
              SizedBox(width: 12),
              Icon(Icons.person_outline, color: TColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  // Set the preferred size for the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
