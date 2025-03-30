// Third-party package imports
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class UsageTrackingService {
  static final UsageTrackingService _instance = UsageTrackingService._internal();
  factory UsageTrackingService() => _instance;
  UsageTrackingService._internal();

  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  Future<void> trackTranslationUsage({
    required int textLength,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return;

    final usageData = {
      'timestamp': firestore.FieldValue.serverTimestamp(),
      'textLength': textLength,
      'units': (textLength / 100).ceil(),
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
    };

    // Add to usage collection
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('translations')
        .add(usageData);

    // Update total usage
    await _updateTotalUsage(userId, usageData['units'] as int);
  }

  Future<void> _updateTotalUsage(String userId, int units) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        transaction.set(userRef, {
          'totalUnitsUsed': units,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });
      } else {
        final currentTotal = userDoc.data()?['totalUnitsUsed'] ?? 0;
        transaction.update(userRef, {
          'totalUnitsUsed': currentTotal + units,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<Map<String, dynamic>> getUserUsageStats() async {
    final userId = await getCurrentUserId();
    if (userId == null) return {};

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final translations = await _firestore
        .collection('users')
        .doc(userId)
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return {
      'totalUnitsUsed': userDoc.data()?['totalUnitsUsed'] ?? 0,
      'lastUpdated': userDoc.data()?['lastUpdated'],
      'recentTranslations': translations.docs.map((doc) => doc.data()).toList(),
    };
  }

  Future<Map<String, int>> getLanguageUsageStats() async {
    final userId = await getCurrentUserId();
    if (userId == null) return {};

    final translations = await _firestore
        .collection('users')
        .doc(userId)
        .collection('translations')
        .get();

    final languageStats = <String, int>{};
    
    for (var doc in translations.docs) {
      final data = doc.data();
      final sourceLang = data['sourceLanguage'] as String;
      final targetLang = data['targetLanguage'] as String;
      final units = data['units'] as int;

      // Track source language usage
      languageStats[sourceLang] = (languageStats[sourceLang] ?? 0) + units;
      // Track target language usage
      languageStats[targetLang] = (languageStats[targetLang] ?? 0) + units;
    }

    return languageStats;
  }

  Future<List<Map<String, dynamic>>> getUsageHistory({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return [];

    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('translations')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
} 