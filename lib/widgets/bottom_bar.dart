import 'package:flight_bocking/home_search/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'colors.dart';
import '../menu.dart';

import '../support.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        items:  [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.bagChecked),
            label: 'Bookings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic_outlined),
            label: 'Support',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              Get.off(() => const HomeScreen());
              break;
            case 1:
              // Get.off(() => BookingsPage());
              break;
            case 2:
              Get.off(() => const SupportScreen());
              break;
            case 3:
              Get.off(() => const MenuScreen());
              break;
          }
        },
      ),
    );
  }
}
