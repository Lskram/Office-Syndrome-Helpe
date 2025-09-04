import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import 'dart:convert';

import '../data/models/user_settings.dart';
import '../data/models/notification_session.dart';
import '../data/models/treatment.dart';
import '../data/models/pain_point.dart';

class DatabaseService {
  static const String _userSettingsBoxName = 'user_settings';
  static const String _sessionsBoxName = 'notification_sessions';
  static const String _treatmentsBoxName = 'treatments';
  static const String _painPointsBoxName = 'pain_points';
  static const String _statisticsBoxName = 'statistics';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyName = 'hive_encryption_key';

  static late Box<UserSettings> _userSettingsBox;
  static late Box<NotificationSession> _sessionsBox;
  static late Box<Treatment> _treatmentsBox;
  static late Box<PainPoint> _painPointsBox;
  static late Box<Map> _statisticsBox;

  static Future<void> initialize() async {
    try {
      // Get encryption key
      final encryptionKey = await _getEncryptionKey();

      // Open encrypted boxes
      _userSettingsBox = await Hive.openBox<UserSettings>(
        _userSettingsBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      _sessionsBox = await Hive.openBox<NotificationSession>(
        _sessionsBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      _treatmentsBox = await Hive.openBox<Treatment>(
        _treatmentsBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      _painPointsBox = await Hive.openBox<PainPoint>(
        _painPointsBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      _statisticsBox = await Hive.openBox<Map>(
        _statisticsBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      // Initialize default data if needed
      await _initializeDefaultData();

      print('Database initialized successfully');
    } catch (e) {
      print('Database initialization error: $e');
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  static Future<Uint8List> _getEncryptionKey() async {
    try {
      // Check if key exists
      String? keyString = await _secureStorage.read(key: _encryptionKeyName);

      if (keyString == null) {
        // Generate new key
        final key = Hive.generateSecureKey();
        keyString = base64Encode(key);
        await _secureStorage.write(key: _encryptionKeyName, value: keyString);
        return key;
      } else {
        // Use existing key
        return base64Decode(keyString);
      }
    } catch (e) {
      print('Error getting encryption key: $e');
      // Fallback to default key (less secure but allows app to work)
      return Uint8List.fromList(List.filled(32, 0));
    }
  }

  static Future<void> _initializeDefaultData() async {
    // Initialize treatments if empty
    if (_treatmentsBox.isEmpty) {
      final treatments = Treatment.getAllTreatments();
      for (final treatment in treatments) {
        await _treatmentsBox.put(treatment.id, treatment);
      }
      print('Initialized ${treatments.length} treatments');
    }

    // Initialize pain points if empty
    if (_painPointsBox.isEmpty) {
      final painPoints = PainPoint.getAllPainPoints();
      for (final painPoint in painPoints) {
        await _painPointsBox.put(painPoint.id, painPoint);
      }
      print('Initialized ${painPoints.length} pain points');
    }

    // Initialize user settings if empty
    if (_userSettingsBox.isEmpty) {
      final defaultSettings = UserSettings.createDefault();
      await _userSettingsBox.put('settings', defaultSettings);
      print('Initialized default user settings');
    }
  }

  // User Settings methods
  static Future<UserSettings> loadSettings() async {
    try {
      final settings = _userSettingsBox.get('settings');
      if (settings == null) {
        final defaultSettings = UserSettings.createDefault();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
      return settings;
    } catch (e) {
      print('Error loading settings: $e');
      return UserSettings.createDefault();
    }
  }

  static Future<void> saveSettings(UserSettings settings) async {
    try {
      await _userSettingsBox.put('settings', settings);
    } catch (e) {
      print('Error saving settings: $e');
      throw DatabaseException('Failed to save settings');
    }
  }

  // Session methods
  static Future<void> saveSession(NotificationSession session) async {
    try {
      await _sessionsBox.put(session.id, session);
    } catch (e) {
      print('Error saving session: $e');
      throw DatabaseException('Failed to save session');
    }
  }

  static NotificationSession? getSession(String sessionId) {
    try {
      return _sessionsBox.get(sessionId);
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }

  static List<NotificationSession> getAllSessions() {
    try {
      return _sessionsBox.values.toList();
    } catch (e) {
      print('Error getting all sessions: $e');
      return [];
    }
  }

  static List<NotificationSession> getSessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return _sessionsBox.values
          .where(
            (session) =>
                session.createdAt.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                session.createdAt.isBefore(
                  endDate.add(const Duration(days: 1)),
                ),
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error getting sessions by date range: $e');
      return [];
    }
  }

  static Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionsBox.delete(sessionId);
    } catch (e) {
      print('Error deleting session: $e');
    }
  }

  // Treatment methods
  static Treatment? getTreatment(int treatmentId) {
    try {
      return _treatmentsBox.get(treatmentId);
    } catch (e) {
      print('Error getting treatment: $e');
      return null;
    }
  }

  static List<Treatment> getAllTreatments() {
    try {
      return _treatmentsBox.values.toList();
    } catch (e) {
      print('Error getting all treatments: $e');
      return Treatment.getAllTreatments();
    }
  }

  static List<Treatment> getTreatmentsByPainPoint(int painPointId) {
    try {
      return _treatmentsBox.values
          .where((treatment) => treatment.painPointId == painPointId)
          .toList();
    } catch (e) {
      print('Error getting treatments by pain point: $e');
      return [];
    }
  }

  static Future<void> saveTreatment(Treatment treatment) async {
    try {
      await _treatmentsBox.put(treatment.id, treatment);
    } catch (e) {
      print('Error saving treatment: $e');
      throw DatabaseException('Failed to save treatment');
    }
  }

  static Future<void> deleteTreatment(int treatmentId) async {
    try {
      await _treatmentsBox.delete(treatmentId);
    } catch (e) {
      print('Error deleting treatment: $e');
    }
  }

  // Pain Point methods
  static PainPoint? getPainPoint(int painPointId) {
    try {
      return _painPointsBox.get(painPointId);
    } catch (e) {
      print('Error getting pain point: $e');
      return PainPoint.findById(painPointId);
    }
  }

  static List<PainPoint> getAllPainPoints() {
    try {
      return _painPointsBox.values.toList();
    } catch (e) {
      print('Error getting all pain points: $e');
      return PainPoint.getAllPainPoints();
    }
  }

  // Statistics methods
  static Future<void> saveStatistic(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      await _statisticsBox.put(key, data);
    } catch (e) {
      print('Error saving statistic: $e');
    }
  }

  static Map<String, dynamic>? getStatistic(String key) {
    try {
      final data = _statisticsBox.get(key);
      return data?.cast<String, dynamic>();
    } catch (e) {
      print('Error getting statistic: $e');
      return null;
    }
  }

  // Utility methods
  static Future<void> clearAllData() async {
    try {
      await _userSettingsBox.clear();
      await _sessionsBox.clear();
      await _treatmentsBox.clear();
      await _painPointsBox.clear();
      await _statisticsBox.clear();

      // Reinitialize default data
      await _initializeDefaultData();

      print('All data cleared and reinitialized');
    } catch (e) {
      print('Error clearing data: $e');
      throw DatabaseException('Failed to clear data');
    }
  }

  static Future<Map<String, dynamic>> exportData() async {
    try {
      final settings = await loadSettings();
      final sessions = getAllSessions();
      final treatments = getAllTreatments().where((t) => t.isCustom).toList();

      return {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'settings': {
          'selectedPainPoints': settings.selectedPainPoints,
          'notificationInterval': settings.notificationInterval,
          'workStartTime': settings.workStartTimeString,
          'workEndTime': settings.workEndTimeString,
          'workingDays': settings.workingDays,
          'breakPeriods': settings.breakPeriods
              .map(
                (bp) => {
                  'startTime': bp.startTimeString,
                  'endTime': bp.endTimeString,
                  'name': bp.name,
                },
              )
              .toList(),
          'soundEnabled': settings.soundEnabled,
          'vibrationEnabled': settings.vibrationEnabled,
          'languageCode': settings.languageCode,
        },
        'customTreatments': treatments
            .map(
              (t) => {
                'id': t.id,
                'nameTh': t.nameTh,
                'nameEn': t.nameEn,
                'descriptionTh': t.descriptionTh,
                'descriptionEn': t.descriptionEn,
                'durationSeconds': t.durationSeconds,
                'painPointId': t.painPointId,
              },
            )
            .toList(),
        'sessions': sessions
            .map(
              (s) => {
                'id': s.id,
                'scheduledTime': s.scheduledTime.toIso8601String(),
                'painPointId': s.painPointId,
                'treatmentIds': s.treatmentIds,
                'status': s.status.name,
                'completedTime': s.completedTime?.toIso8601String(),
                'sessionDurationSeconds': s.sessionDurationSeconds,
              },
            )
            .toList(),
      };
    } catch (e) {
      print('Error exporting data: $e');
      throw DatabaseException('Failed to export data');
    }
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Validate data format
      if (data['version'] != '1.0') {
        throw DatabaseException('Unsupported data version');
      }

      // Import settings
      if (data['settings'] != null) {
        final settingsData = data['settings'];
        final settings = UserSettings(
          selectedPainPoints: List<int>.from(
            settingsData['selectedPainPoints'] ?? [3, 4, 5],
          ),
          notificationInterval: settingsData['notificationInterval'] ?? 60,
          workStartTimeString: settingsData['workStartTime'] ?? '09:00',
          workEndTimeString: settingsData['workEndTime'] ?? '17:00',
          workingDays: List<int>.from(
            settingsData['workingDays'] ?? [1, 2, 3, 4, 5],
          ),
          soundEnabled: settingsData['soundEnabled'] ?? true,
          vibrationEnabled: settingsData['vibrationEnabled'] ?? true,
          languageCode: settingsData['languageCode'] ?? 'th',
          hasRequestedPermissions: true, // Set to true for imported data
        );

        if (settingsData['breakPeriods'] != null) {
          settings.breakPeriods = (settingsData['breakPeriods'] as List)
              .map(
                (bp) => BreakPeriod(
                  startTimeString: bp['startTime'],
                  endTimeString: bp['endTime'],
                  name: bp['name'],
                ),
              )
              .toList();
        }

        await saveSettings(settings);
      }

      // Import custom treatments
      if (data['customTreatments'] != null) {
        for (final treatmentData in data['customTreatments']) {
          final treatment = Treatment(
            id: treatmentData['id'],
            nameTh: treatmentData['nameTh'],
            nameEn: treatmentData['nameEn'],
            descriptionTh: treatmentData['descriptionTh'],
            descriptionEn: treatmentData['descriptionEn'],
            durationSeconds: treatmentData['durationSeconds'],
            painPointId: treatmentData['painPointId'],
            isCustom: true,
          );
          await saveTreatment(treatment);
        }
      }

      print('Data imported successfully');
    } catch (e) {
      print('Error importing data: $e');
      throw DatabaseException('Failed to import data');
    }
  }

  // Session cleanup - remove old sessions (older than 30 days)
  static Future<void> cleanupOldSessions() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      final oldSessions = _sessionsBox.values
          .where((session) => session.createdAt.isBefore(cutoffDate))
          .toList();

      for (final session in oldSessions) {
        await _sessionsBox.delete(session.id);
      }

      if (oldSessions.isNotEmpty) {
        print('Cleaned up ${oldSessions.length} old sessions');
      }
    } catch (e) {
      print('Error cleaning up old sessions: $e');
    }
  }

  // Getters for boxes (if needed for advanced operations)
  static Box<UserSettings> get userSettingsBox => _userSettingsBox;
  static Box<NotificationSession> get sessionsBox => _sessionsBox;
  static Box<Treatment> get treatmentsBox => _treatmentsBox;
  static Box<PainPoint> get painPointsBox => _painPointsBox;
  static Box<Map> get statisticsBox => _statisticsBox;
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
