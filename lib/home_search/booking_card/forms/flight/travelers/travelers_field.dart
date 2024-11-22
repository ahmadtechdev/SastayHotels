import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../../../widgets/colors.dart';
import 'traveler_controller.dart';

class TravelersField extends StatefulWidget {
  const TravelersField({
    super.key,
  });

  @override
  _TravelersFieldState createState() => _TravelersFieldState();
}

class _TravelersFieldState extends State<TravelersField> {
  final TravelersController controller = Get.put(TravelersController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTravelersDialog(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: TColors.primary),
              const SizedBox(width: 12),
              Obx(() => Text('${controller.adultCount.value} Adults, '
                  '${controller.childrenCount.value} Children, '
                  '${controller.infantCount.value} Infants, '
                  '${controller.travelClass.value}')),
            ],
          ),
        ),
      ),
    );
  }

  void _showTravelersDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTravelerRow('Adult', controller.adultCount, MdiIcons.humanMaleFemale),
                  const SizedBox(height: 16),
                  _buildTravelerRow('Children', controller.childrenCount, Icons.child_care),
                  const SizedBox(height: 16),
                  _buildTravelerRow('Infants', controller.infantCount,
                      MdiIcons.babyCarriage, isInfant: true),
                  const SizedBox(height: 24),
                  const Text('Class',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildClassSelection(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTravelerRow(String label, RxInt count,  IconData icon, {bool isInfant = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              isInfant ? '7 days to 23 months' : '12 years or above',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Obx(() => Row(
              children: [
                IconButton(
                  onPressed: label == 'Adult'
                      ? controller.decrementAdults
                      : label == 'Children'
                          ? controller.decrementChildren
                          : controller.decrementInfants,
                  icon: const Icon(Icons.remove_circle_outline, color: TColors.primary,),
                ),
                Text('${count.value}'),
                IconButton(
                  onPressed: label == 'Adult'
                      ? controller.incrementAdults
                      : label == 'Children'
                          ? controller.incrementChildren
                          : controller.incrementInfants,
                  icon: const Icon(Icons.add_circle_outline, color: TColors.primary),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildClassSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClassRadio('Economy'),
        _buildClassRadio('Premium Economy'),
        _buildClassRadio('Business'),
        _buildClassRadio('First'),
      ],
    );
  }

  Widget _buildClassRadio(String className) {
    return Obx(() => RadioListTile<String>(
          title: Text(className),
          value: className,
          groupValue: controller.travelClass.value,
          onChanged: (value) {
            controller.updateTravelClass(value!);
          },
        ));
  }
}
