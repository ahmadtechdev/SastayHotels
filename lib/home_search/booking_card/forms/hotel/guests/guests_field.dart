import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../widgets/colors.dart';
import 'guests_controller.dart';

class GuestsField extends StatefulWidget {
  const GuestsField({super.key});

  @override
  State<GuestsField> createState() => _GuestsFieldState();
}

class _GuestsFieldState extends State<GuestsField> {
  final GuestsController controller = Get.put(GuestsController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showGuestsDialog(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline, color: TColors.primary),
            const SizedBox(width: 12),
            Obx(() {
              // Automatically update the UI based on controller values
              final totalAdults = controller.adultsPerRoom.reduce((a, b) => a + b);
              final totalChildren = controller.childrenPerRoom.reduce((a, b) => a + b);
              return Text(
                '${controller.roomCount.value} Rooms, $totalAdults Adults, $totalChildren Children',
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showGuestsDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRoomsRow(),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: controller.roomCount.value,
                    itemBuilder: (context, index) {
                      return _buildGuestsRow(index + 1);
                    },
                  )),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoomsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Rooms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Obx(() => Row(
          children: [
            IconButton(
              onPressed: controller.decrementRooms,
              icon: const Icon(Icons.remove_circle_outline, color: TColors.primary),
            ),
            Text('${controller.roomCount.value}'),
            IconButton(
              onPressed: controller.incrementRooms,
              icon: const Icon(Icons.add_circle_outline, color: TColors.primary),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildGuestsRow(int roomNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Room $roomNumber - Guests',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.primary)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Adults'),
            Obx(() => Row(
              children: [
                IconButton(
                  onPressed: () => controller.decrementAdults(roomNumber),
                  icon: const Icon(Icons.remove_circle_outline, color: TColors.primary),
                ),
                Text('${controller.adultsPerRoom[roomNumber - 1]}'),
                IconButton(
                  onPressed: () => controller.incrementAdults(roomNumber),
                  icon: const Icon(Icons.add_circle_outline, color: TColors.primary),
                ),
              ],
            )),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Children'),
            Obx(() => Row(
              children: [
                IconButton(
                  onPressed: () => controller.decrementChildren(roomNumber),
                  icon: const Icon(Icons.remove_circle_outline, color: TColors.primary),
                ),
                Text('${controller.childrenPerRoom[roomNumber - 1]}'),
                IconButton(
                  onPressed: () => controller.incrementChildren(roomNumber),
                  icon: const Icon(Icons.add_circle_outline, color: TColors.primary),
                ),
              ],
            )),
          ],
        ),
      ],
    );
  }
}
