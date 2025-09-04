import 'package:hive/hive.dart';

part 'treatment.g.dart';

@HiveType(typeId: 4)
class Treatment extends HiveObject {
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
  int durationSeconds;

  @HiveField(6)
  int painPointId;

  @HiveField(7)
  bool isCustom; // ผู้ใช้สร้างเองหรือไม่

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? imageUrl; // สำหรับรูปภาพประกอบ (optional)

  Treatment({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.descriptionTh,
    required this.descriptionEn,
    required this.durationSeconds,
    required this.painPointId,
    this.isCustom = false,
    DateTime? createdAt,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  String getName(String languageCode) {
    return languageCode == 'th' ? nameTh : nameEn;
  }

  String getDescription(String languageCode) {
    return languageCode == 'th' ? descriptionTh : descriptionEn;
  }

  String get formattedDuration {
    if (durationSeconds < 60) {
      return '$durationSeconds วิ';
    } else {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      if (seconds == 0) {
        return '$minutes นาที';
      } else {
        return '$minutes:${seconds.toString().padLeft(2, '0')} นาที';
      }
    }
  }

  String get formattedDurationEn {
    if (durationSeconds < 60) {
      return '${durationSeconds}s';
    } else {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      if (seconds == 0) {
        return '${minutes}min';
      } else {
        return '${minutes}:${seconds.toString().padLeft(2, '0')}min';
      }
    }
  }

  // Static data - ฐานข้อมูล 25 ท่าตาม requirement
  static List<Treatment> getAllTreatments() {
    return [
      // ศีรษะ (painPointId: 1) - 3 ท่า
      Treatment(
        id: 1,
        nameTh: 'หายใจลึกเพื่อความสงบ',
        nameEn: 'Deep Breathing for Relaxation',
        descriptionTh: 'นั่งตัวตรง หายใจเข้า-ออกลึกๆ 3 ครั้ง ช่วยให้ผ่อนคลาย',
        descriptionEn: 'Sit straight and take 3 deep breaths for relaxation',
        durationSeconds: 30,
        painPointId: 1,
      ),
      Treatment(
        id: 2,
        nameTh: 'กดจุดคลายเครียด',
        nameEn: 'Pressure Point Relief',
        descriptionTh: 'ใช้นิ้วชี้กดจุดระหว่างคิ้วเบาๆ 10 วินาที',
        descriptionEn:
            'Use index finger to gently press between eyebrows for 10 seconds',
        durationSeconds: 10,
        painPointId: 1,
      ),
      Treatment(
        id: 3,
        nameTh: 'นวดขมับเป็นวงกลม',
        nameEn: 'Temple Massage',
        descriptionTh: 'นวดเบาๆ ที่ขมับเป็นวงกลมทั้งสองข้าง 30 วินาที',
        descriptionEn:
            'Gently massage temples in circular motion for 30 seconds',
        durationSeconds: 30,
        painPointId: 1,
      ),

      // ตา (painPointId: 2) - 3 ท่า
      Treatment(
        id: 4,
        nameTh: 'หลับตา-ลืมตา',
        nameEn: 'Blink Exercise',
        descriptionTh: 'หลับตาแน่น 5 วิ แล้วลืม ทำซ้ำ 5 รอบ',
        descriptionEn:
            'Close eyes tight for 5 seconds, then open. Repeat 5 times',
        durationSeconds: 25,
        painPointId: 2,
      ),
      Treatment(
        id: 5,
        nameTh: 'กฎ 20-20-20',
        nameEn: '20-20-20 Rule',
        descriptionTh: 'มองไกลออกไป 20 ฟุต นาน 20 วินาที',
        descriptionEn: 'Look at something 20 feet away for 20 seconds',
        durationSeconds: 20,
        painPointId: 2,
      ),
      Treatment(
        id: 6,
        nameTh: 'กลอกตามอง',
        nameEn: 'Eye Rolling',
        descriptionTh: 'กลอกตามองบน-ล่าง-ซ้าย-ขวา ช้าๆ',
        descriptionEn: 'Slowly roll eyes up-down-left-right',
        durationSeconds: 30,
        painPointId: 2,
      ),

      // คอ (painPointId: 3) - 2 ท่า
      Treatment(
        id: 7,
        nameTh: 'เคลื่อนไหวคอ 4 ทิศ',
        nameEn: '4-Direction Neck Movement',
        descriptionTh: 'ก้มคางแตะอก > เงยหน้า > หันซ้าย > หันขวา ช้าๆ',
        descriptionEn:
            'Chin to chest > Look up > Turn left > Turn right slowly',
        durationSeconds: 40,
        painPointId: 3,
      ),
      Treatment(
        id: 8,
        nameTh: 'ยืดคอข้างๆ',
        nameEn: 'Side Neck Stretch',
        descriptionTh: 'เอียงคอไปข้างหนึ่ง ใช้มือนึงกดเบาๆ ค้าง 10 วิ ทำสลับ',
        descriptionEn:
            'Tilt neck to one side, gently press with hand for 10s each side',
        durationSeconds: 20,
        painPointId: 3,
      ),

      // บ่าและไหล่ (painPointId: 4) - 3 ท่า
      Treatment(
        id: 9,
        nameTh: 'ยกไหล่ขึ้น-ลง',
        nameEn: 'Shoulder Shrugs',
        descriptionTh: 'ยกไหล่ทั้งสองขึ้นให้สูงสุด แล้วปล่อยลง 10 ครั้ง',
        descriptionEn:
            'Lift both shoulders up as high as possible, then drop. 10 times',
        durationSeconds: 30,
        painPointId: 4,
      ),
      Treatment(
        id: 10,
        nameTh: 'หมุนไหล่',
        nameEn: 'Shoulder Rolls',
        descriptionTh: 'หมุนไหล่ไปข้างหน้า 10 รอบ แล้วย้อนกลับ',
        descriptionEn: 'Roll shoulders forward 10 times, then backward',
        durationSeconds: 40,
        painPointId: 4,
      ),
      Treatment(
        id: 11,
        nameTh: 'กอดตัวเองยืดไหล่',
        nameEn: 'Self-Hug Shoulder Stretch',
        descriptionTh: 'กอดตัวเองแน่นๆ แล้วยืดไหล่ออก',
        descriptionEn: 'Hug yourself tight and stretch shoulders out',
        durationSeconds: 20,
        painPointId: 4,
      ),

      // หลังส่วนบน (painPointId: 5) - 3 ท่า
      Treatment(
        id: 12,
        nameTh: 'ประสานมือยืดหลัง',
        nameEn: 'Interlaced Hand Back Stretch',
        descriptionTh: 'ประสานมือยืดไปหน้าให้สุด งอหลัง',
        descriptionEn: 'Interlace hands, stretch forward and curve back',
        durationSeconds: 30,
        painPointId: 5,
      ),
      Treatment(
        id: 13,
        nameTh: 'ยืดแขนข้ามอก',
        nameEn: 'Cross-Body Arm Stretch',
        descriptionTh: 'ยืดแขนข้ามอก กดด้วยมืออีกข้าง',
        descriptionEn: 'Stretch arm across body, press with other hand',
        durationSeconds: 15,
        painPointId: 5,
      ),
      Treatment(
        id: 14,
        nameTh: 'บิดลำตัว',
        nameEn: 'Torso Twist',
        descriptionTh: 'หมุนลำตัวซ้าย-ขวา ช้าๆ',
        descriptionEn: 'Slowly twist torso left and right',
        durationSeconds: 25,
        painPointId: 5,
      ),

      // หลังส่วนล่าง (painPointId: 6) - 2 ท่า
      Treatment(
        id: 15,
        nameTh: 'บิดตัวนั่ง',
        nameEn: 'Seated Spinal Twist',
        descriptionTh: 'นั่งบิดตัวซ้าย-ขวา ค้างข้างละ 15 วิ',
        descriptionEn: 'Sit and twist left-right, hold 15 seconds each side',
        durationSeconds: 30,
        painPointId: 6,
      ),
      Treatment(
        id: 16,
        nameTh: 'งอตัวจับเท้า',
        nameEn: 'Forward Bend to Ankles',
        descriptionTh: 'งอตัวไปข้างหน้า จับข้อเท้า',
        descriptionEn: 'Bend forward and reach for ankles',
        durationSeconds: 20,
        painPointId: 6,
      ),

      // แขน/ศอก (painPointId: 7) - 2 ท่า
      Treatment(
        id: 17,
        nameTh: 'หมุนข้อมือ',
        nameEn: 'Wrist Rotations',
        descriptionTh: 'เหยียดแขนตรง หมุนข้อมือ 10 รอบ',
        descriptionEn: 'Extend arms straight, rotate wrists 10 times',
        durationSeconds: 20,
        painPointId: 7,
      ),
      Treatment(
        id: 18,
        nameTh: 'งอ-เหยียดศอก',
        nameEn: 'Elbow Flexion',
        descriptionTh: 'งอ-เหยียดศอก 10 ครั้ง ทั้งสองข้าง',
        descriptionEn: 'Flex and extend elbows 10 times both sides',
        durationSeconds: 25,
        painPointId: 7,
      ),

      // ข้อมือ/มือ/นิ้ว (painPointId: 8) - 3 ท่า
      Treatment(
        id: 19,
        nameTh: 'กำมือ-กางนิ้ว',
        nameEn: 'Fist-Finger Spread',
        descriptionTh: 'กำมือแน่น แล้วกางนิ้ว 10 ครั้ง',
        descriptionEn: 'Make tight fists, then spread fingers wide. 10 times',
        durationSeconds: 20,
        painPointId: 8,
      ),
      Treatment(
        id: 20,
        nameTh: 'หมุนข้อมือ',
        nameEn: 'Wrist Circles',
        descriptionTh: 'หมุนข้อมือทั้งสองข้าง 10 รอบ',
        descriptionEn: 'Rotate both wrists 10 times each direction',
        durationSeconds: 20,
        painPointId: 8,
      ),
      Treatment(
        id: 21,
        nameTh: 'ยืดฝ่ามือ',
        nameEn: 'Palm Stretch',
        descriptionTh: 'กดฝ่ามือด้วยมืออีกข้าง ยืดนิ้ว',
        descriptionEn: 'Press palm with other hand, stretch fingers back',
        durationSeconds: 25,
        painPointId: 8,
      ),

      // ขา (painPointId: 9) - 2 ท่า
      Treatment(
        id: 22,
        nameTh: 'ยกเท้าสลับ',
        nameEn: 'Alternating Leg Lifts',
        descriptionTh: 'ยกเท้าสลับซ้าย-ขวา 20 ครั้ง',
        descriptionEn: 'Alternate lifting left-right feet 20 times',
        durationSeconds: 30,
        painPointId: 9,
      ),
      Treatment(
        id: 23,
        nameTh: 'กอดเข่าเข้าอก',
        nameEn: 'Knee to Chest',
        descriptionTh: 'นั่งยืดขา งอเข่าเข้าหาอก',
        descriptionEn: 'Sit, extend leg, then bring knee to chest',
        durationSeconds: 20,
        painPointId: 9,
      ),

      // เท้า (painPointId: 10) - 2 ท่า
      Treatment(
        id: 24,
        nameTh: 'หมุนข้อเท้า',
        nameEn: 'Ankle Rotations',
        descriptionTh: 'หมุนข้อเท้าทั้งสองข้าง 10 รอบ',
        descriptionEn: 'Rotate both ankles 10 times each direction',
        durationSeconds: 20,
        painPointId: 10,
      ),
      Treatment(
        id: 25,
        nameTh: 'เหยียบส้น-ปลาย',
        nameEn: 'Heel-Toe Rocks',
        descriptionTh: 'เหยียบส้นเท้า-ปลายเท้าสลับ 20 ครั้ง',
        descriptionEn: 'Rock from heel to toe alternately 20 times',
        durationSeconds: 25,
        painPointId: 10,
      ),
    ];
  }
}
