import 'package:hive/hive.dart';

part 'pain_point.g.dart';

@HiveType(typeId: 5)
class PainPoint extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String nameTh;

  @HiveField(2)
  String nameEn;

  @HiveField(3)
  String descriptionTh;

  @HiveField(4)
  String descriptionEn;

  @HiveField(5)
  String iconName; // Icon name for UI

  PainPoint({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.descriptionTh,
    required this.descriptionEn,
    required this.iconName,
  });

  String getName(String languageCode) {
    return languageCode == 'th' ? nameTh : nameEn;
  }

  String getDescription(String languageCode) {
    return languageCode == 'th' ? descriptionTh : descriptionEn;
  }

  // Static data - 10 จุดตาม requirement
  static List<PainPoint> getAllPainPoints() {
    return [
      PainPoint(
        id: 1,
        nameTh: 'ศีรษะ',
        nameEn: 'Head',
        descriptionTh: 'ปวดหัว เครียด อ่อนเพลีย',
        descriptionEn: 'Headache, stress, fatigue',
        iconName: 'head',
      ),
      PainPoint(
        id: 2,
        nameTh: 'ตา',
        nameEn: 'Eyes',
        descriptionTh: 'ตาแห้ง เบลอ ปวดรอบดวงตา',
        descriptionEn: 'Dry eyes, blurred vision, eye strain',
        iconName: 'visibility',
      ),
      PainPoint(
        id: 3,
        nameTh: 'คอ',
        nameEn: 'Neck',
        descriptionTh: 'คอแข็ง เมื่อยคอ หมุนคอลำบาก',
        descriptionEn: 'Stiff neck, neck pain, limited movement',
        iconName: 'accessibility_new',
      ),
      PainPoint(
        id: 4,
        nameTh: 'บ่าและไหล่',
        nameEn: 'Shoulders',
        descriptionTh: 'บ่าเป็นปม ไหล่แข็ง ยกแขนเจ็บ',
        descriptionEn: 'Shoulder knots, stiffness, pain when lifting',
        iconName: 'fitness_center',
      ),
      PainPoint(
        id: 5,
        nameTh: 'หลังส่วนบน',
        nameEn: 'Upper Back',
        descriptionTh: 'หลังบนเจ็บ กล้ามเนื้อเกร็ง',
        descriptionEn: 'Upper back pain, muscle tension',
        iconName: 'airline_seat_recline_normal',
      ),
      PainPoint(
        id: 6,
        nameTh: 'หลังส่วนล่าง',
        nameEn: 'Lower Back',
        descriptionTh: 'ปวดหลังล่าง เอาไปจากการนั่งนาน',
        descriptionEn: 'Lower back pain from prolonged sitting',
        iconName: 'event_seat',
      ),
      PainPoint(
        id: 7,
        nameTh: 'แขน/ศอก',
        nameEn: 'Arms/Elbows',
        descriptionTh: 'แขนเมื่อย ศอกแข็ง จากการใช้เมาส์',
        descriptionEn: 'Arm fatigue, elbow stiffness from mouse use',
        iconName: 'back_hand',
      ),
      PainPoint(
        id: 8,
        nameTh: 'ข้อมือ/มือ/นิ้ว',
        nameEn: 'Wrists/Hands/Fingers',
        descriptionTh: 'ข้อมือเจ็บ นิ้วแข็ง จากการพิมพ์',
        descriptionEn: 'Wrist pain, finger stiffness from typing',
        iconName: 'pan_tool',
      ),
      PainPoint(
        id: 9,
        nameTh: 'ขา',
        nameEn: 'Legs',
        descriptionTh: 'ขาเมื่อย เลือดไหลเวียนไม่ดี',
        descriptionEn: 'Leg fatigue, poor circulation',
        iconName: 'directions_walk',
      ),
      PainPoint(
        id: 10,
        nameTh: 'เท้า',
        nameEn: 'Feet',
        descriptionTh: 'เท้าบวม ข้อเท้าแข็ง',
        descriptionEn: 'Swollen feet, ankle stiffness',
        iconName: 'directions_run',
      ),
    ];
  }

  static PainPoint? findById(int id) {
    try {
      return getAllPainPoints().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
