// Dart core imports
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Local imports
import 'package:lingowise/services/usage_tracking_service.dart' as usage;
import 'package:lingowise/services/subscription_service.dart' as subscription;

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  late prefs.SharedPreferences _prefs;
  static const String _apiKey = 'AIzaSyAHGIdW9Zz4tGMcDjS_AnQcmwKB-bdH25w'; // Replace with your API key
  static const String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  final usage.UsageTrackingService _usageTracking = usage.UsageTrackingService();
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  Future<void> init() async {
    _prefs = await prefs.SharedPreferences.getInstance();
  }

  Future<String> getSourceLanguage() async {
    return _prefs.getString('source_language_code') ?? 'en';
  }

  Future<String> getTargetLanguage() async {
    return _prefs.getString('target_language_code') ?? 'es';
  }

  Future<String> translate(String text) async {
    try {
      final sourceLang = await getSourceLanguage();
      final targetLang = await getTargetLanguage();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText = data['data']['translations'][0]['translatedText'];
        
        // Track usage after successful translation
        await _usageTracking.trackTranslationUsage(
          textLength: text.length,
          sourceLanguage: sourceLang,
          targetLanguage: targetLang,
        );
        
        return translatedText;
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }

  Future<bool> hasEnoughUnits(int textLength) async {
    final subscriptionService = subscription.SubscriptionService();
    final currentUnits = await subscriptionService.getUnits();
    // Estimate 1 unit per 100 characters
    final requiredUnits = (textLength / 100).ceil();
    return currentUnits >= requiredUnits;
  }

  Future<void> useUnits(int textLength) async {
    final subscriptionService = subscription.SubscriptionService();
    // Estimate 1 unit per 100 characters
    final requiredUnits = (textLength / 100).ceil();
    await subscriptionService.useUnits(requiredUnits);
  }

  // Get usage statistics
  Future<Map<String, dynamic>> getUsageStats() async {
    return _usageTracking.getUserUsageStats();
  }

  // Get language usage statistics
  Future<Map<String, int>> getLanguageUsageStats() async {
    return _usageTracking.getLanguageUsageStats();
  }

  // Get usage history
  Future<List<Map<String, dynamic>>> getUsageHistory({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _usageTracking.getUsageHistory(
      limit: limit,
      startDate: startDate,
      endDate: endDate,
    );
  }
} 