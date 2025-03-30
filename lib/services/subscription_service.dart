// Flutter imports

// Third-party package imports
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

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

  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  late prefs.SharedPreferences _prefs;
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

  Future<void> initialize() async {
    _prefs = await prefs.SharedPreferences.getInstance();
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

  Future<void> updateSubscriptionStatus(
      String userId, String packageId, int units) async {
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (!userDoc.exists) {
        transaction.set(userRef, {
          'subscriptionPackageId': packageId,
          'remainingUnits': units,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(userRef, {
          'subscriptionPackageId': packageId,
          'remainingUnits': units,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    await _prefs.setString('subscriptionPackageId', packageId);
    await _prefs.setInt('remainingUnits', units);
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return {};

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return {};

    return {
      'packageId': userDoc.data()?['subscriptionPackageId'],
      'remainingUnits': userDoc.data()?['remainingUnits'] ?? 0,
      'lastUpdated': userDoc.data()?['lastUpdated'],
    };
  }

  Future<bool> hasActiveSubscription() async {
    final status = await getSubscriptionStatus();
    return status['remainingUnits'] > 0;
  }

  Future<DateTime?> getLastUsage() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;

    final lastUpdated = userDoc.data()?['lastUpdated'];
    return lastUpdated != null
        ? (lastUpdated as firestore.Timestamp).toDate()
        : null;
  }

  Future<int> getRemainingUnits() async {
    final status = await getSubscriptionStatus();
    return status['remainingUnits'] ?? 0;
  }

  Future<void> addUnits(int units) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (userDoc.exists) {
        final currentUnits = userDoc.data()?['remainingUnits'] ?? 0;
        final newUnits = currentUnits + units;

        transaction.update(userRef, {
          'remainingUnits': newUnits,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });

        await _prefs.setInt('remainingUnits', newUnits);
      } else {
        transaction.set(userRef, {
          'subscriptionPackageId': 'custom', // You can set an appropriate ID
          'remainingUnits': units,
          'lastUpdated': firestore.FieldValue.serverTimestamp(),
        });

        await _prefs.setString('subscriptionPackageId', 'custom');
        await _prefs.setInt('remainingUnits', units);
      }
    });

    // Notify listeners about the change
    _notifyListeners(true);
  }

  Future<void> deductUnits(int units) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);

      if (userDoc.exists) {
        final currentUnits = userDoc.data()?['remainingUnits'] ?? 0;
        final newUnits = currentUnits - units;

        if (newUnits >= 0) {
          transaction.update(userRef, {
            'remainingUnits': newUnits,
            'lastUpdated': firestore.FieldValue.serverTimestamp(),
          });

          await _prefs.setInt('remainingUnits', newUnits);
        }
      }
    });
  }

  Future<void> resetSubscription() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userRef, {
        'subscriptionPackageId': null,
        'remainingUnits': 0,
        'lastUpdated': firestore.FieldValue.serverTimestamp(),
      });
    });

    await _prefs.remove('subscriptionPackageId');
    await _prefs.setInt('remainingUnits', 0);
  }
}
