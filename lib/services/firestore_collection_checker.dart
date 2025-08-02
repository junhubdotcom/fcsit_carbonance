import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steadypunpipi_vhack/services/database_services.dart';

/// Utility service to check and list all Firestore collections
/// This helps you understand what collections exist in your database
class FirestoreCollectionChecker {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all collections in your Firestore database
  /// Note: Firestore doesn't have a direct listCollections method
  /// This is a simplified version that checks known collections
  Future<List<String>> getAllCollections() async {
    try {
      print("🔍 [CHECKER] Checking known Firestore collections...");

      // List of collections to check (production collections)
      final collectionsToCheck = [
        // Production collections
        FirestoreCollections.EXPENSES,
        FirestoreCollections.INCOMES,
        FirestoreCollections.EXPENSE_ITEMS,
        FirestoreCollections.CONNECT_EARTH_INSIGHTS,
        FirestoreCollections.INSIGHTS_SUMMARY,
        FirestoreCollections.TRIGGERS,
      ];

      final existingCollections = <String>[];

      for (String collectionName in collectionsToCheck) {
        try {
          final snapshot =
              await _firestore.collection(collectionName).limit(1).get();
          existingCollections.add(collectionName);
        } catch (e) {
          // Collection doesn't exist or access denied
          print("   ❌ $collectionName: Access denied or doesn't exist");
        }
      }

      print(
          "📊 [CHECKER] Found ${existingCollections.length} accessible collections:");
      for (String name in existingCollections) {
        print("   📁 $name");
      }

      return existingCollections;
    } catch (e) {
      print("❌ [CHECKER] Error checking collections: $e");
      return [];
    }
  }

  /// Check if expected collections exist
  Future<Map<String, bool>> checkExpectedCollections() async {
    final expectedCollections = [
      FirestoreCollections.EXPENSES,
      FirestoreCollections.INCOMES,
      FirestoreCollections.EXPENSE_ITEMS,
      FirestoreCollections.CONNECT_EARTH_INSIGHTS,
      FirestoreCollections.INSIGHTS_SUMMARY,
    ];

    final existingCollections = await getAllCollections();
    final results = <String, bool>{};

    print("\n✅ [CHECKER] Checking expected collections:");
    for (String expected in expectedCollections) {
      final exists = existingCollections.contains(expected);
      results[expected] = exists;
      print("   ${exists ? '✅' : '❌'} $expected");
    }

    return results;
  }

  /// Get document count for each collection
  Future<Map<String, int>> getCollectionDocumentCounts() async {
    final collections = await getAllCollections();
    final counts = <String, int>{};

    print("\n📈 [CHECKER] Getting document counts:");
    for (String collectionName in collections) {
      try {
        final snapshot = await _firestore.collection(collectionName).get();
        counts[collectionName] = snapshot.docs.length;
        print("   📊 $collectionName: ${snapshot.docs.length} documents");
      } catch (e) {
        print("   ❌ Error counting $collectionName: $e");
        counts[collectionName] = -1;
      }
    }

    return counts;
  }

  /// Comprehensive collection analysis
  Future<void> analyzeCollections() async {
    print("🔍 [CHECKER] Starting comprehensive collection analysis...\n");

    // Get all collections
    final collections = await getAllCollections();

    // Check expected collections
    final expectedCheck = await checkExpectedCollections();

    // Get document counts
    final counts = await getCollectionDocumentCounts();

    // Summary
    print("\n📋 [CHECKER] Analysis Summary:");
    print("   Total collections found: ${collections.length}");

    final missingCollections = expectedCheck.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();

    if (missingCollections.isNotEmpty) {
      print(
          "   Missing expected collections: ${missingCollections.join(', ')}");
    } else {
      print("   ✅ All expected collections exist");
    }

    final totalDocuments = counts.values
        .where((count) => count > 0)
        .fold(0, (sum, count) => sum + count);
    print("   Total documents across all collections: $totalDocuments");
  }

  /// Check for legacy collections that should be migrated
  Future<List<String>> findLegacyCollections() async {
    final legacyCollections = [
      "test",
      "testIncome",
      "testItem",
      "Income",
      "Expense",
      "ConnectEarthInsights",
      "InsightsSummary"
    ];

    final existingCollections = await getAllCollections();
    final foundLegacy = existingCollections
        .where((name) => legacyCollections.contains(name))
        .toList();

    if (foundLegacy.isNotEmpty) {
      print("\n⚠️ [CHECKER] Found legacy collections that should be migrated:");
      for (String legacy in foundLegacy) {
        print("   🔄 $legacy");
      }
    } else {
      print("\n✅ [CHECKER] No legacy collections found");
    }

    return foundLegacy;
  }
}

/// Extension to easily use the checker
extension FirestoreCheckerExtension on FirebaseFirestore {
  FirestoreCollectionChecker get checker => FirestoreCollectionChecker();
}
