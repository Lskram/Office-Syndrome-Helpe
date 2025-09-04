import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../controllers/home_controller.dart';
import '../widgets/live_countdown_widget.dart';
import '../widgets/pain_points_display_widget.dart';
import '../widgets/quick_stats_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🏠 Office Syndrome Helper'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Notification options button
              IconButton(
                onPressed: controller.showNotificationOptions,
                icon: const Icon(Icons.more_vert),
                tooltip: 'ตัวเลือกการแจ้งเตือน',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pain Points Display
                  const PainPointsDisplayWidget(),
                  const SizedBox(height: 16),

                  // Notification Status Card
                  _buildNotificationStatusCard(controller),
                  const SizedBox(height: 16),

                  // Live Countdown Widget
                  const LiveCountdownWidget(),
                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  _buildQuickActionButtons(controller),
                  const SizedBox(height: 16),

                  // Today's Statistics
                  const QuickStatsWidget(),
                  const SizedBox(height: 16),

                  // Current Session Card (if exists)
                  Obx(() {
                    if (controller.hasActiveSession) {
                      return _buildCurrentSessionCard(controller);
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationStatusCard(HomeController controller) {
    return Obx(() {
      return Card(
        color: controller.statusCardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    controller.notificationStatusIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'สถานะการแจ้งเตือน',
                    style: Theme.of(Get.context!).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    controller.notificationStatusText,
                    style: TextStyle(
                      color: controller.statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                controller.statusText.value,
                style: TextStyle(color: controller.statusTextColor),
              ),
              if (controller.isNotificationEnabled) ...[
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: controller.progressValue.value,
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Theme.of(Get.context!).primaryColor,
                  barRadius: const Radius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.progressPercentage}% ผ่านไปแล้ว',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActionButtons(HomeController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.science,
            label: 'ทดสอบ',
            onPressed: controller.testNotification,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.analytics,
            label: 'สถิติ',
            onPressed: controller.goToStatistics,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.settings,
            label: 'ตั้งค่า',
            onPressed: controller.goToSettings,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionCard(HomeController controller) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  'มีกิจกรรมรอดำเนินการ',
                  style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'มีท่าออกกำลังกายรอให้ทำ กดปุ่มด้านล่างเพื่อดูรายละเอียด',
              style: TextStyle(color: Colors.blue.shade600),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.goToTodo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ดูกิจกรรม'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
