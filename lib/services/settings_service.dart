import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _messageSoundKey = 'message_sound_enabled';
  static const String _messageVibrationKey = 'message_vibration_enabled';
  static const String _onlineStatusKey = 'online_status_visible';
  static const String _typingIndicatorKey = 'typing_indicator_enabled';
  static const String _readReceiptsKey = 'read_receipts_enabled';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Settings
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.toString());
  }

  ThemeMode getThemeMode() {
    final themeString = _prefs.getString(_themeKey);
    return themeString == null
        ? ThemeMode.system
        : ThemeMode.values.firstWhere(
            (e) => e.toString() == themeString,
          );
  }

  // Language Settings
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  // Notification Settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  // Message Sound Settings
  Future<void> setMessageSoundEnabled(bool enabled) async {
    await _prefs.setBool(_messageSoundKey, enabled);
  }

  bool getMessageSoundEnabled() {
    return _prefs.getBool(_messageSoundKey) ?? true;
  }

  // Message Vibration Settings
  Future<void> setMessageVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_messageVibrationKey, enabled);
  }

  bool getMessageVibrationEnabled() {
    return _prefs.getBool(_messageVibrationKey) ?? true;
  }

  // Online Status Settings
  Future<void> setOnlineStatusVisible(bool visible) async {
    await _prefs.setBool(_onlineStatusKey, visible);
  }

  bool getOnlineStatusVisible() {
    return _prefs.getBool(_onlineStatusKey) ?? true;
  }

  // Typing Indicator Settings
  Future<void> setTypingIndicatorEnabled(bool enabled) async {
    await _prefs.setBool(_typingIndicatorKey, enabled);
  }

  bool getTypingIndicatorEnabled() {
    return _prefs.getBool(_typingIndicatorKey) ?? true;
  }

  // Read Receipts Settings
  Future<void> setReadReceiptsEnabled(bool enabled) async {
    await _prefs.setBool(_readReceiptsKey, enabled);
  }

  bool getReadReceiptsEnabled() {
    return _prefs.getBool(_readReceiptsKey) ?? true;
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _prefs.clear();
  }
}
