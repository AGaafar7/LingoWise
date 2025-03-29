import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pay/pay.dart';

class SubscriptionPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int units;
  final bool isFree;

  SubscriptionPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.units,
    this.isFree = false,
  });
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static const String _unitsKey = 'subscription_units';
  static const String _hasSubscriptionKey = 'has_subscription';
  static const String _lastUsageKey = 'last_usage';
  static const int _lowUnitsThreshold = 10;
  late SharedPreferences _prefs;
  List<SubscriptionPackage> _packages = [];
  bool _isInitialized = false;
  final _subscriptionListeners = <Function(bool)>[];

  List<SubscriptionPackage> get packages => _packages;
  bool get isInitialized => _isInitialized;

  void addSubscriptionListener(Function(bool) listener) {
    _subscriptionListeners.add(listener);
  }

  void removeSubscriptionListener(Function(bool) listener) {
    _subscriptionListeners.remove(listener);
  }

  void _notifyListeners(bool hasSubscription) {
    for (final listener in _subscriptionListeners) {
      listener(hasSubscription);
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initializePackages();
    _isInitialized = true;
  }

  void _initializePackages() {
    _packages = [
      SubscriptionPackage(
        id: 'free',
        name: 'Free Plan',
        description: '2 minutes transcription and translation',
        price: 0,
        units: 2,
        isFree: true,
      ),
      SubscriptionPackage(
        id: 'basic',
        name: 'Basic Plan',
        description: '2 hours translation and transcription',
        price: 12,
        units: 120,
      ),
      SubscriptionPackage(
        id: 'standard',
        name: 'Standard Plan',
        description: '4 hours translation and transcription',
        price: 23,
        units: 240,
      ),
      SubscriptionPackage(
        id: 'premium',
        name: 'Premium Plan',
        description: '8 hours translation and transcription',
        price: 43,
        units: 480,
      ),
      SubscriptionPackage(
        id: 'enterprise',
        name: 'Enterprise Plan',
        description: '17 hours translation and transcription',
        price: 85,
        units: 1000,
      ),
    ];
  }

  Future<void> addUnits(int units) async {
    final currentUnits = await getUnits();
    await _prefs.setInt(_unitsKey, currentUnits + units);
    await _prefs.setBool(_hasSubscriptionKey, true);
    _notifyListeners(true);
  }

  Future<int> getUnits() async {
    return _prefs.getInt(_unitsKey) ?? 0;
  }

  Future<bool> hasSubscription() async {
    return _prefs.getBool(_hasSubscriptionKey) ?? false;
  }

  Future<bool> useUnits(int minutes) async {
    final currentUnits = await getUnits();
    if (currentUnits >= minutes) {
      await _prefs.setInt(_unitsKey, currentUnits - minutes);
      await _prefs.setString(_lastUsageKey, DateTime.now().toIso8601String());

      // Check if units are running low
      if (currentUnits - minutes <= _lowUnitsThreshold) {
        _notifyListeners(false);
      }

      // Check if units are depleted
      if (currentUnits - minutes <= 0) {
        await _prefs.setBool(_hasSubscriptionKey, false);
        _notifyListeners(false);
      }

      return true;
    }
    return false;
  }

  Future<DateTime?> getLastUsage() async {
    final lastUsageStr = _prefs.getString(_lastUsageKey);
    if (lastUsageStr != null) {
      return DateTime.parse(lastUsageStr);
    }
    return null;
  }

  Future<bool> isRunningLowOnUnits() async {
    final currentUnits = await getUnits();
    return currentUnits <= _lowUnitsThreshold;
  }

  Future<void> clearSubscription() async {
    await _prefs.setBool(_hasSubscriptionKey, false);
    await _prefs.setInt(_unitsKey, 0);
    _notifyListeners(false);
  }
} 