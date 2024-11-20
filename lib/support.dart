// support_screen.dart
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'widgets/colors.dart';
import 'widgets/bottom_bar.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/img/newLogo.png', // Make sure to add the logo asset
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
                    children: [
                      Icon(MdiIcons.whatsapp, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
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
                SizedBox(width: 12),
                Icon(Icons.headset_mic_outlined, color: TColors.primary),
                SizedBox(width: 12),
                Icon(Icons.person_outline, color: TColors.primary),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect with us 24/7',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              ),
              SizedBox(height: 32),
              _buildSupportOption(
                icon: Icons.phone,
                title: 'Call us now',
                subtitle: '+92 21-111-172-782',
                iconColor: TColors.primary,
              ),
              SizedBox(height: 24),
              _buildSupportOption(
                icon: MdiIcons.whatsapp,
                title: 'Whatsapp support',
                subtitle: '+92 304 777 2782',
                iconColor: Colors.green,
              ),
              SizedBox(height: 24),
              _buildSupportOption(
                icon: Icons.chat_bubble_outline,
                title: 'Chat support',
                subtitle: 'Chat with us',
                subtitleColor: TColors.secondary,
                iconColor: TColors.primary,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Support tab

      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    Color? subtitleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: TColors.text,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: subtitleColor ?? TColors.grey,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: TColors.grey),
      ),
    );
  }
}