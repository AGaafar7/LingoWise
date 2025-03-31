import 'package:dio/dio.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/api_tracking_service.dart';

class TrackedStreamChatClient extends StreamChatClient {
  final ApiTrackingService _trackingService = ApiTrackingService();
  final String userId;
  final Dio dio = Dio(); // Create a custom Dio instance

  TrackedStreamChatClient(String apiKey, {required this.userId})
      : super(apiKey, logLevel: Level.INFO) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.extra['startTime'] = DateTime.now();
        return handler.next(options);
      },
      onResponse:
          (Response response, ResponseInterceptorHandler handler) async {
        final startTime =
            response.requestOptions.extra['startTime'] as DateTime?;
        final responseTime = startTime != null
            ? DateTime.now().difference(startTime).inMilliseconds
            : 0;

        await _trackingService.trackApiCall(
          endpoint: response.requestOptions.path,
          method: response.requestOptions.method,
          statusCode: response.statusCode ?? 200,
          responseTime: responseTime,
          userId: userId,
          metadata: {
            'queryParams': response.requestOptions.queryParameters,
            'data': response.requestOptions.data,
          },
        );

        return handler.next(response);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final startTime = e.requestOptions.extra['startTime'] as DateTime?;
        final responseTime = startTime != null
            ? DateTime.now().difference(startTime).inMilliseconds
            : 0;

        await _trackingService.trackApiCall(
          endpoint: e.requestOptions.path,
          method: e.requestOptions.method,
          statusCode: e.response?.statusCode ?? 500,
          responseTime: responseTime,
          userId: userId,
          metadata: {
            'error': e.message,
            'queryParams': e.requestOptions.queryParameters,
            'data': e.requestOptions.data,
          },
        );

        return handler.next(e);
      },
    ));
  }

  /// 🔹 Generate a Stream Chat token (for development)
  Future<String> createToken(String userId) async {
    final token = devToken(userId).rawValue;
    print("Generated Stream Chat Token: $token");

    if (token.isEmpty) {
      throw Exception("❌ Failed to generate Stream Chat token.");
    }

    // ✅ Set the Authorization header globally for all Dio requests
    dio.options.headers['Authorization'] = "Bearer $token";

    return token;
  }

  /// 🔹 Make an API call using Dio instead of modifying StreamChatClient's httpClient
  Future<Response> makeTrackedApiCall(String method, String endpoint,
      {Map<String, dynamic>? queryParams, Map<String, dynamic>? data}) async {
    final startTime = DateTime.now();

    try {
      final token = devToken(userId).rawValue;
      print("Using token for API call: $token");

      final options = Options(headers: {
        'Authorization': "Bearer $token",
      });

      Response response;
      if (method == 'GET') {
        response = await dio.get(endpoint,
            queryParameters: queryParams, options: options);
      } else if (method == 'POST') {
        response = await dio.post(endpoint,
            data: data, queryParameters: queryParams, options: options);
      } else if (method == 'PUT') {
        response = await dio.put(endpoint,
            data: data, queryParameters: queryParams, options: options);
      } else if (method == 'DELETE') {
        response = await dio.delete(endpoint,
            queryParameters: queryParams, options: options);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      await _trackingService.trackApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: response.statusCode ?? 200,
        responseTime: responseTime,
        userId: userId,
        metadata: {
          'queryParams': queryParams,
          'data': data,
        },
      );

      return response;
    } catch (e) {
      final responseTime = DateTime.now().difference(startTime).inMilliseconds;

      await _trackingService.trackApiCall(
        endpoint: endpoint,
        method: method,
        statusCode: 500,
        responseTime: responseTime,
        userId: userId,
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
