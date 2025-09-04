import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class PainPointsDisplayWidget extends StatelessWidget {
  const PainPointsDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      '📍 จุดที่ดูแลอยู่',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.goToSettings,
                      child: const Text('แก้ไข'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.selectedPainPoints.isEmpty) {
                    return _buildEmptyState(controller);
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.selectedPainPoints
                        .map((painPoint) => _buildPainPointChip(painPoint))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(HomeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Colors.orange.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'ยังไม่ได้เลือกจุดที่ปวด',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'กรุณาไปที่การตั้งค่าเพื่อเลือกจุดที่ปวดบ่อย',
            style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.goToSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('ไปเลือกจุดที่ปวด'),
          ),
        ],
      ),
    );
  }

  Widget _buildPainPointChip(dynamic painPoint) {
    // Get language from settings
    String languageCode = 'th';
    try {
      if (Get.isRegistered<SettingsController>()) {
        languageCode = Get.find<SettingsController>().currentLanguage.value;
      }
    } catch (e) {
      // Use default language
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForPainPoint(painPoint.id),
            size: 16,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            painPoint.getName(languageCode),
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForPainPoint(int painPointId) {
    switch (painPointId) {
      case 1: // ศีรษะ
        return Icons.psychology;
      case 2: // ตา
        return Icons.visibility;
      case 3: // คอ
        return Icons.accessibility_new;
      case 4: // บ่าและไหล่
        return Icons.fitness_center;
      case 5: // หลังส่วนบน
        return Icons.airline_seat_recline_normal;
      case 6: // หลังส่วนล่าง
        return Icons.event_seat;
      case 7: // แขน/ศอก
        return Icons.back_hand;
      case 8: // ข้อมือ/มือ/นิ้ว
        return Icons.pan_tool;
      case 9: // ขา
        return Icons.directions_walk;
      case 10: // เท้า
        return Icons.directions_run;
      default:
        return Icons.help_outline;
    }
  }
}
