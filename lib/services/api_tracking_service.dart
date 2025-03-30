import 'package:cloud_firestore/cloud_firestore.dart';

class ApiTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ApiTrackingService _instance = ApiTrackingService._internal();
  factory ApiTrackingService() => _instance;
  ApiTrackingService._internal();

  Future<void> trackApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int responseTime,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final timestamp = DateTime.now();
      final usageData = {
        'endpoint': endpoint,
        'method': method,
        'statusCode': statusCode,
        'responseTime': responseTime,
        'userId': userId,
        'timestamp': timestamp,
        'metadata': metadata,
      };

      await _firestore.collection('api_usage').add(usageData);
    } catch (e) {
      print('Error tracking API call: $e');
    }
  }

  Future<Map<String, dynamic>> getUsageStats({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
  }) async {
    try {
      Query query = _firestore.collection('api_usage');

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      
      int totalCalls = snapshot.docs.length;
      int successfulCalls = snapshot.docs.where((doc) => doc['statusCode'] < 400).length;
      int failedCalls = totalCalls - successfulCalls;
      
      double avgResponseTime = snapshot.docs.isEmpty
          ? 0
          : snapshot.docs.map((doc) => doc['responseTime'] as int).reduce((a, b) => a + b) / totalCalls;

      return {
        'totalCalls': totalCalls,
        'successfulCalls': successfulCalls,
        'failedCalls': failedCalls,
        'averageResponseTime': avgResponseTime,
        'successRate': totalCalls > 0 ? (successfulCalls / totalCalls) * 100 : 0,
      };
    } catch (e) {
      print('Error getting usage stats: $e');
      return {
        'totalCalls': 0,
        'successfulCalls': 0,
        'failedCalls': 0,
        'averageResponseTime': 0,
        'successRate': 0,
      };
    }
  }
} 
