import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/period_counters.dart';

class PeriodCountersService {
  static final PeriodCountersService _instance =
      PeriodCountersService._internal();
  factory PeriodCountersService() => _instance;
  PeriodCountersService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PERIOD ID GENERATION ====================

  /// Generate period ID for daily counter
  String generateDailyPeriodId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}+GMT8';
  }

  /// Generate period ID for weekly counter
  String generateWeeklyPeriodId(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final year = startOfWeek.year;
    final weekOfYear =
        ((startOfWeek.difference(DateTime(year, 1, 1)).inDays) / 7).floor() + 1;
    return '$year-W${weekOfYear.toString().padLeft(2, '0')}+GMT8';
  }

  /// Generate period ID for monthly counter
  String generateMonthlyPeriodId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}+GMT8';
  }

  /// Generate document ID for period counter
  String generateDocumentId(String userId, String period, String periodId) {
    return '${userId}_${period}_$periodId';
  }

  // ==================== CRUD OPERATIONS ====================

  /// Get period counter by ID
  Future<PeriodCounters?> getPeriodCounter({
    required String userId,
    required String period,
    required String periodId,
  }) async {
    try {
      final docId = generateDocumentId(userId, period, periodId);
      final doc =
          await _firestore.collection('period_counters').doc(docId).get();

      if (doc.exists) {
        return PeriodCounters.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching period counter: $e');
      return null;
    }
  }

  /// Create or update period counter
  Future<void> upsertPeriodCounter({
    required String userId,
    required String period,
    required String periodId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docId = generateDocumentId(userId, period, periodId);
      await _firestore
          .collection('period_counters')
          .doc(docId)
          .set(data, SetOptions(merge: true));
      print('✅ Period counter upserted: $docId');
    } catch (e) {
      print('❌ Error upserting period counter: $e');
      rethrow;
    }
  }

  /// Update period counter
  Future<void> updatePeriodCounter({
    required String userId,
    required String period,
    required String periodId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docId = generateDocumentId(userId, period, periodId);
      await _firestore.collection('period_counters').doc(docId).update(data);
      print('✅ Period counter updated: $docId');
    } catch (e) {
      print('❌ Error updating period counter: $e');
      rethrow;
    }
  }

  /// Delete period counter
  Future<void> deletePeriodCounter({
    required String userId,
    required String period,
    required String periodId,
  }) async {
    try {
      final docId = generateDocumentId(userId, period, periodId);
      await _firestore.collection('period_counters').doc(docId).delete();
      print('✅ Period counter deleted: $docId');
    } catch (e) {
      print('❌ Error deleting period counter: $e');
      rethrow;
    }
  }

  // ==================== REAL-TIME STREAMS ====================

  /// Stream for daily counter
  Stream<PeriodCounters?> getDailyCounterStream({
    required String userId,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final periodId = generateDailyPeriodId(targetDate);
    final docId = generateDocumentId(userId, 'daily', periodId);

    return _firestore
        .collection('period_counters')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PeriodCounters.fromJson(doc.id, doc.data()!);
      }
      return null;
    });
  }

  /// Stream for weekly counter
  Stream<PeriodCounters?> getWeeklyCounterStream({
    required String userId,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final periodId = generateWeeklyPeriodId(targetDate);
    final docId = generateDocumentId(userId, 'weekly', periodId);

    return _firestore
        .collection('period_counters')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PeriodCounters.fromJson(doc.id, doc.data()!);
      }
      return null;
    });
  }

  /// Stream for monthly counter
  Stream<PeriodCounters?> getMonthlyCounterStream({
    required String userId,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final periodId = generateMonthlyPeriodId(targetDate);
    final docId = generateDocumentId(userId, 'monthly', periodId);

    return _firestore
        .collection('period_counters')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PeriodCounters.fromJson(doc.id, doc.data()!);
      }
      return null;
    });
  }

  // ==================== BATCH OPERATIONS ====================

  /// Get all period counters for a user
  Future<List<PeriodCounters>> getAllPeriodCounters({
    required String userId,
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('period_counters')
          .where('userId', isEqualTo: userId)
          .orderBy('lastUpdated', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        return PeriodCounters.fromJson(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching all period counters: $e');
      return [];
    }
  }

  /// Get period counters by date range
  Future<List<PeriodCounters>> getPeriodCountersByDateRange({
    required String userId,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startPeriodId = period == 'daily'
          ? generateDailyPeriodId(startDate)
          : period == 'weekly'
              ? generateWeeklyPeriodId(startDate)
              : generateMonthlyPeriodId(startDate);

      final endPeriodId = period == 'daily'
          ? generateDailyPeriodId(endDate)
          : period == 'weekly'
              ? generateWeeklyPeriodId(endDate)
              : generateMonthlyPeriodId(endDate);

      final snapshot = await _firestore
          .collection('period_counters')
          .where('userId', isEqualTo: userId)
          .where('period', isEqualTo: period)
          .where('periodId', isGreaterThanOrEqualTo: startPeriodId)
          .where('periodId', isLessThanOrEqualTo: endPeriodId)
          .orderBy('periodId')
          .get();

      return snapshot.docs.map((doc) {
        return PeriodCounters.fromJson(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching period counters by date range: $e');
      return [];
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if period counter exists
  Future<bool> periodCounterExists({
    required String userId,
    required String period,
    required String periodId,
  }) async {
    try {
      final docId = generateDocumentId(userId, period, periodId);
      final doc =
          await _firestore.collection('period_counters').doc(docId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking period counter existence: $e');
      return false;
    }
  }

  /// Get current period IDs
  Map<String, String> getCurrentPeriodIds() {
    final now = DateTime.now();
    return {
      'daily': generateDailyPeriodId(now),
      'weekly': generateWeeklyPeriodId(now),
      'monthly': generateMonthlyPeriodId(now),
    };
  }

  /// Get period IDs for a specific date
  Map<String, String> getPeriodIdsForDate(DateTime date) {
    return {
      'daily': generateDailyPeriodId(date),
      'weekly': generateWeeklyPeriodId(date),
      'monthly': generateMonthlyPeriodId(date),
    };
  }
}
