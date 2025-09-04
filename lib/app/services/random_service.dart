import 'dart:math';
import '../services/database_service.dart';

class RandomService {
  static final Random _random = Random();

  /// สุ่มเลือก 1 จุดที่ปวดจากรายการที่ผู้ใช้เลือกไว้
  static int selectRandomPainPoint(List<int> selectedPainPoints) {
    if (selectedPainPoints.isEmpty) {
      throw Exception('No pain points selected');
    }

    final randomIndex = _random.nextInt(selectedPainPoints.length);
    return selectedPainPoints[randomIndex];
  }

  /// สุ่มเลือกท่าออกกำลังกาย จำนวน count ท่า จากจุดที่ปวดที่กำหนด
  /// ไม่ให้ซ้ำกันในรอบเดียว
  static List<int> selectRandomTreatments(int painPointId, int count) {
    final allTreatments = DatabaseService.getTreatmentsByPainPoint(painPointId);

    if (allTreatments.isEmpty) {
      throw Exception('No treatments found for pain point $painPointId');
    }

    if (count > allTreatments.length) {
      // ถ้าต้องการมากกว่าที่มี ให้คืนทั้งหมด
      return allTreatments.map((t) => t.id).toList();
    }

    // สุ่มเลือกแบบไม่ซ้ำ
    final treatmentIds = allTreatments.map((t) => t.id).toList();
    treatmentIds.shuffle(_random);

    return treatmentIds.take(count).toList();
  }

  /// สุ่มเลือกท่าออกกำลังกายแบบไม่ซ้ำจากหลายๆ จุดที่ปวด
  static List<int> selectMixedRandomTreatments(
    List<int> painPointIds,
    int totalCount,
  ) {
    if (painPointIds.isEmpty) {
      throw Exception('No pain points provided');
    }

    final allTreatments = <int>[];

    // เก็บท่าจากทุกจุดที่ปวด
    for (final painPointId in painPointIds) {
      final treatments = DatabaseService.getTreatmentsByPainPoint(painPointId);
      allTreatments.addAll(treatments.map((t) => t.id));
    }

    if (allTreatments.isEmpty) {
      throw Exception('No treatments found for provided pain points');
    }

    // สุ่มและเลือก
    allTreatments.shuffle(_random);
    return allTreatments.take(totalCount).toList();
  }

  /// สร้างลำดับแบบสุ่มสำหรับการออกกำลังกาย
  static List<int> createRandomExerciseSequence(List<int> treatmentIds) {
    final sequence = List<int>.from(treatmentIds);
    sequence.shuffle(_random);
    return sequence;
  }

  /// เลือกช่วงเวลาแบบสุ่มภายในขอบเขตที่กำหนด
  static int selectRandomInterval({
    required int minMinutes,
    required int maxMinutes,
  }) {
    if (minMinutes >= maxMinutes) {
      return minMinutes;
    }

    return minMinutes + _random.nextInt(maxMinutes - minMinutes + 1);
  }

  /// เลือกเวลาแบบสุ่มภายในวัน (สำหรับทดสอบ)
  static DateTime selectRandomTimeInDay({
    DateTime? baseDate,
    int? minHour,
    int? maxHour,
  }) {
    final date = baseDate ?? DateTime.now();
    final startHour = minHour ?? 9;
    final endHour = maxHour ?? 17;

    final randomHour = startHour + _random.nextInt(endHour - startHour);
    final randomMinute = _random.nextInt(60);

    return DateTime(date.year, date.month, date.day, randomHour, randomMinute);
  }

  /// สุ่มเลือกข้อความแจ้งเตือน
  static String selectRandomNotificationTitle(String painPointName) {
    final titles = [
      "⏰ ถึงเวลาดูแล: $painPointName",
      "💪 มาออกกำลังกาย: $painPointName กันเถอะ",
      "🧘‍♀️ พักจากงาน ดูแล$painPointName",
      "✨ เวลาดูแลสุขภาพ: $painPointName",
      "🏃‍♂️ ช่วงพักเพื่อ$painPointName",
    ];

    return titles[_random.nextInt(titles.length)];
  }

  static String selectRandomNotificationBody() {
    final bodies = [
      "กดเพื่อดูท่าออกกำลังกาย",
      "มาดูแลสุขภาพกันเถอะ",
      "ท่าง่ายๆ ที่จะช่วยให้คุณสดชื่น",
      "แค่ 2-3 นาที ก็ช่วยได้แล้ว",
      "ออกกำลังกายเบาๆ เพื่อสุขภาพ",
    ];

    return bodies[_random.nextInt(bodies.length)];
  }

  /// ฟังก์ชันช่วยเหลือสำหรับการทดสอบ
  static void seedRandom(int seed) {
    // ใช้สำหรับทดสอบเพื่อให้ได้ผลลัพธ์ที่คาดเดาได้
    // ใน production ไม่ควรเรียกใช้
  }

  /// สร้างรายการท่าที่สมดุลจากทุกจุดที่เลือก
  static List<int> createBalancedTreatmentList(
    List<int> painPointIds,
    int totalTreatments,
  ) {
    if (painPointIds.isEmpty) return [];

    final selectedTreatments = <int>[];
    final treatmentsPerPainPoint = totalTreatments ~/ painPointIds.length;
    final remainder = totalTreatments % painPointIds.length;

    // เลือกท่าจากแต่ละจุดเท่าๆ กัน
    for (int i = 0; i < painPointIds.length; i++) {
      final painPointId = painPointIds[i];
      final countForThisPainPoint =
          treatmentsPerPainPoint + (i < remainder ? 1 : 0);

      final treatments = selectRandomTreatments(
        painPointId,
        countForThisPainPoint,
      );
      selectedTreatments.addAll(treatments);
    }

    // สุ่มลำดับ
    selectedTreatments.shuffle(_random);
    return selectedTreatments;
  }

  /// เลือกท่าที่เหมาะสมตามเวลาที่มี
  static List<int> selectTreatmentsByDuration(
    int painPointId,
    int targetDurationSeconds,
  ) {
    final allTreatments = DatabaseService.getTreatmentsByPainPoint(painPointId);
    if (allTreatments.isEmpty) return [];

    // เรียงตามระยะเวลา
    allTreatments.sort(
      (a, b) => a.durationSeconds.compareTo(b.durationSeconds),
    );

    final selectedTreatments = <int>[];
    int totalDuration = 0;

    // เลือกท่าที่รวมแล้วใกล้เคียงกับเวลาเป้าหมาย
    for (final treatment in allTreatments) {
      if (totalDuration + treatment.durationSeconds <= targetDurationSeconds) {
        selectedTreatments.add(treatment.id);
        totalDuration += treatment.durationSeconds;
      }

      if (totalDuration >= targetDurationSeconds * 0.8) {
        // ถ้าได้อย่างน้อย 80% ของเวลาเป้าหมายแล้ว ให้หยุด
        break;
      }
    }

    // ถ้ายังไม่มีท่าใดๆ ให้เลือกท่าสั้นที่สุด
    if (selectedTreatments.isEmpty && allTreatments.isNotEmpty) {
      selectedTreatments.add(allTreatments.first.id);
    }

    return selectedTreatments;
  }

  /// สร้างแผนการออกกำลังกายแบบสุ่มสำหรับทั้งสัปดาห์
  static Map<int, List<int>> createWeeklyExercisePlan(
    List<int> painPointIds,
    List<int> workingDays,
  ) {
    final weeklyPlan = <int, List<int>>{};

    for (final day in workingDays) {
      // สุ่มเลือกจุดที่ปวดสำหรับแต่ละวัน
      final dailyPainPoint = selectRandomPainPoint(painPointIds);
      final dailyTreatments = selectRandomTreatments(dailyPainPoint, 2);
      weeklyPlan[day] = dailyTreatments;
    }

    return weeklyPlan;
  }

  /// ตรวจสอบว่าการสุ่มมีความหลากหลายเพียงพอหรือไม่
  static bool isSelectionDiverseEnough(
    List<int> recentSelections,
    int newSelection, {
    int maxRepeatCount = 3,
  }) {
    final recentCount = recentSelections
        .where((selection) => selection == newSelection)
        .length;

    return recentCount < maxRepeatCount;
  }

  /// เลือกแบบสุ่มที่หลีกเลี่ยงการซ้ำซากจากการเลือกล่าสุด
  static int selectWithDiversityCheck(
    List<int> options,
    List<int> recentSelections, {
    int maxRepeatCount = 2,
  }) {
    // กรองตัวเลือกที่ไม่ซ้ำมากเกินไป
    final diverseOptions = options
        .where(
          (option) => isSelectionDiverseEnough(
            recentSelections,
            option,
            maxRepeatCount: maxRepeatCount,
          ),
        )
        .toList();

    // ถ้าไม่มีตัวเลือกที่หลากหลาย ให้เลือกจากทั้งหมด
    final finalOptions = diverseOptions.isNotEmpty ? diverseOptions : options;

    return finalOptions[_random.nextInt(finalOptions.length)];
  }
}
