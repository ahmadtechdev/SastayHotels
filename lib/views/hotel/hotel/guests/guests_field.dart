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

  final GuestsController controller = Get.find<GuestsController>();

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
            Obx(() => Text(
              '${controller.roomCount.value} Rooms, ${controller.totalAdults} Adults, ${controller.totalChildren} Children',
            )),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoomsRow(),
                const SizedBox(height: 24),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: controller.roomCount.value,
                    itemBuilder: (context, index) {
                      return _buildRoomSection(index);
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

  Widget _buildRoomSection(int roomIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Room ${roomIndex + 1}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.primary)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Adults'),
            Obx(() => Row(
              children: [
                IconButton(
                  onPressed: () => controller.decrementAdults(roomIndex),
                  icon: const Icon(Icons.remove_circle_outline, color: TColors.primary),
                ),
                Text('${controller.rooms[roomIndex].adults.value}'),
                IconButton(
                  onPressed: () => controller.incrementAdults(roomIndex),
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
                  onPressed: () => controller.decrementChildren(roomIndex),
                  icon: const Icon(Icons.remove_circle_outline, color: TColors.primary),
                ),
                Text('${controller.rooms[roomIndex].children.value}'),
                IconButton(
                  onPressed: () => controller.incrementChildren(roomIndex),
                  icon: const Icon(Icons.add_circle_outline, color: TColors.primary),
                ),
              ],
            )),
          ],
        ),
        Obx(() => Column(
          children: List.generate(
            controller.rooms[roomIndex].children.value,
                (childIndex) => _buildChildAgeSelector(roomIndex, childIndex),
          ),
        )),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildChildAgeSelector(int roomIndex, int childIndex) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Child ${childIndex + 1} Age'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButton<int>(
              value: controller.rooms[roomIndex].childrenAges[childIndex],
              underline: const SizedBox(),
              items: List.generate(18, (index) => DropdownMenuItem(
                value: index,
                child: Text('$index'),
              )),
              onChanged: (age) {
                if (age != null) {
                  controller.updateChildAge(roomIndex, childIndex, age);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}