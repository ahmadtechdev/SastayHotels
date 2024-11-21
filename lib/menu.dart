// menu_screen.dart
import 'package:flight_bocking/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'widgets/colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/img/newLogo.png',
          height: 30,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children:  [
                      Icon(MdiIcons.whatsapp, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'PKR',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.green, size: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.headset_mic_outlined, color: TColors.primary),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline, color: TColors.primary),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'U3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User 390784',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.text,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Add your email',
                              style: TextStyle(
                                color: TColors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit, size: 16, color: TColors.secondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(),
            _buildMenuItems(),
            const SizedBox(height: 20),
            Text(
              'App version 0.7.73',
              style: TextStyle(
                color: TColors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Menu tab

      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {'icon': Icons.account_balance_wallet, 'title': 'Sasta Wallet'},
      {'icon': Icons.phone, 'title': 'Contact us'},
      {'icon': Icons.info, 'title': 'About Sastaticket.pk'},
      {'icon': Icons.description, 'title': 'Terms & Conditions'},
      {'icon': Icons.privacy_tip, 'title': 'Privacy policy'},
      {'icon': Icons.star_rate, 'title': 'Rate our app'},
      {'icon': Icons.share_outlined, 'title': 'Share our app'},
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: menuItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Padding(
          padding: const EdgeInsets.all(3.0),
          child: ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: TColors.primary,
              size: 24,
            ),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                color: TColors.text,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: TColors.grey,
            ),
            onTap: () {
              // Handle menu item tap
            },
          ),
        );
      },
    );
  }
}