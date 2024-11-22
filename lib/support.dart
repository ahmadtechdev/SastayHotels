// support_screen.dart
import 'package:flight_bocking/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'widgets/colors.dart';
import 'widgets/bottom_bar.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.background,
      appBar:  const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connect with us 24/7',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
              ),
              const SizedBox(height: 32),
              _buildSupportOption(
                icon: Icons.phone,
                title: 'Call us now',
                subtitle: '+92 21-111-172-782',
                iconColor: TColors.primary,
              ),
              const SizedBox(height: 24),
              _buildSupportOption(
                icon: MdiIcons.whatsapp,
                title: 'Whatsapp support',
                subtitle: '+92 304 777 2782',
                iconColor: Colors.green,
              ),
              const SizedBox(height: 24),
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
      bottomNavigationBar: const BottomNavBar(
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: TColors.grey),
      ),
    );
  }
}