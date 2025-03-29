import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/api_tracking_service.dart';

class TrackedStreamChatClient extends StreamChatClient {
  final ApiTrackingService _trackingService = ApiTrackingService();
  final String _userId;

  TrackedStreamChatClient(String apiKey, {required String userId})
      : _userId = userId,
        super(apiKey);

  @override
  Future<Response> send(
    String method,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
  }) async {
    final startTime = DateTime.now();
    
    try {
      final response = await super.send(method, endpoint,
          queryParams: queryParams, data: data);
      
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;
      
      await _trackingService.trackApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: response.statusCode,
        responseTime: responseTime,
        userId: _userId,
        metadata: {
          'queryParams': queryParams,
          'data': data,
        },
      );
      
      return response;
    } catch (e) {
      final endTime = DateTime.now();
      final responseTime = endTime.difference(startTime).inMilliseconds;
      
      await _trackingService.trackApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: 500, // Assuming error status code
        responseTime: responseTime,
        userId: _userId,
        metadata: {
          'error': e.toString(),
          'queryParams': queryParams,
          'data': data,
        },
      );
      
      rethrow;
    }
  }
} 