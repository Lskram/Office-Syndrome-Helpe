import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';

class QuickStatsWidget extends StatelessWidget {
  const QuickStatsWidget({super.key});

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
                    const Icon(Icons.analytics, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '📈 สถิติวันนี้',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.showStatsDialog,
                      child: const Text('ดูเพิ่มเติม'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  if (controller.todayTotal.value == 0) {
                    return _buildEmptyStats();
                  }
                  
                  return _buildStatsContent(controller);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'วันนี้ยังไม่มีกิจกรรม',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'รอการแจ้งเตือนครั้งแรกเพื่อเริ่มสร้างสถิติ',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(HomeController controller) {
    return Column(
      children: [
        // Main stats row
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'แจ้งเตือน',
                value: '${controller.todayTotal.value}',
                unit: 'ครั้ง',
                color: Colors.blue,
                icon: Icons.notifications,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                label: 'ทำเสร็จ',
                value: '${controller.todayCompleted.value}',
                unit: 'ครั้ง',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Success rate bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: controller.successRateColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.successRateColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'อัตราความสำเร็จ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: controller.successRateColor,
                    ),
                  ),
                  Text(
                    controller.successRateText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: controller.successRateColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: controller.todaySuccessRate.value / 100,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(controller.successRateColor),
                minHeight: 6,
              ),
            ],
          ),
        ),
        
        // Average time
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'เวลาเฉลี่ยต่อครั้ง',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            Obx(() {
              return Text(
                controller.averageSessionTime.value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}