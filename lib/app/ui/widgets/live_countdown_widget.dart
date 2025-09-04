import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../controllers/home_controller.dart';

class LiveCountdownWidget extends StatelessWidget {
  const LiveCountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Obx(() {
          if (!controller.isNotificationEnabled) {
            return _buildDisabledState();
          }

          return _buildActiveState(controller);
        });
      },
    );
  }

  Widget _buildActiveState(HomeController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.green.shade600),
                const SizedBox(height: 16),
            Obx(() {
              final timeRemaining = controller.timeRemaining.value;
              if (timeRemaining == "กำลังประมวลผล...") {
                return _buildProcessingState();
              }
              
              return Column(
                children: [
                  Text(
                    "แจ้งเตือนถัดไปใน",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeRemaining,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: controller.progressValue.value,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${controller.progressPercentage}% ผ่านไปแล้ว",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledState() {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.notifications_off, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'การแจ้งเตือนปิดอยู่',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'เปิดการแจ้งเตือนเพื่อให้แอปช่วยเตือนคุณออกกำลังกาย',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final controller = Get.find<HomeController>();
                  controller.enableNotifications();
                },
                child: const Text('เปิดการแจ้งเตือน'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(height: 12),
        Text(
          "กำลังประมวลผลเวลาถัดไป...",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}width: 8),
                Text(
                  'การนับถอยหลัง',
                  style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(