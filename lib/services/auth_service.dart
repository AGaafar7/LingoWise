import 'dart:async' show Completer;

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart'
    show AlertDialog, BuildContext, Navigator, Text, TextButton, showDialog;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lingowise/main.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/tracked_stream_chat_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lingowise/services/settings_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TrackedStreamChatClient? _streamClient;
  bool _isInitializing = false;
  static const String _clientKey = 'stream_chat_client';
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SettingsService _settingsService = SettingsService();

  // ✅ Get current user
  fb_auth.User? get currentUser => _auth.currentUser;

  // ✅ Get Stream Chat client
  TrackedStreamChatClient? get streamClient => _streamClient;

  // ✅ Stream of auth state changes
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Initialize Stream Chat client for a user
  Future<void> initializeStreamClient(String userId) async {
    if (_isInitializing) {
      print("⏳ Stream Chat initialization already in progress...");
      return;
    }

    if (_streamClient != null && _streamClient!.state.currentUser != null) {
      print(
          "✅ Stream Chat already initialized for user: ${_streamClient!.state.currentUser!.id}");
      return;
    }

    _isInitializing = true;
    print("🔹 Starting Stream Chat initialization for user: $userId");

    try {
      // Try to get existing client from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedClient = prefs.getString(_clientKey);

      if (savedClient != null) {
        print("🔍 Found existing Stream Chat client");
        final apikey = "8w7w6b93ktuu";
        _streamClient = TrackedStreamChatClient(apikey, userId: userId);

        // Try to reconnect with saved token
        final token = await _streamClient!.createToken(userId);
        await _streamClient!.connectUser(
          User(id: userId, role: 'admin'),
          token,
        );

        if (_streamClient!.state.currentUser != null) {
          print("✅ Successfully reconnected to Stream Chat");
          return;
        }
      }

      // If no saved client or reconnection failed, create new client
      final apikey = "8w7w6b93ktuu";
      final client = TrackedStreamChatClient(apikey, userId: userId);

      // Generate token
      final token = await client.createToken(userId);
      print("🔹 Stream Chat token generated successfully");

      // Connect user
      await client.connectUser(
        User(id: userId, role: 'admin'),
        token,
      );

      // Verify connection
      if (client.state.currentUser == null) {
        throw Exception(
            "❌ Stream Chat authentication failed - no current user");
      }

      print(
          "✅ Stream Chat user authenticated: ${client.state.currentUser!.id}");
      _streamClient = client;

      // Save client state
      await prefs.setString(_clientKey, userId);
    } catch (e) {
      print("❌ Error initializing Stream Chat: $e");
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  // ✅ Check if username exists in Firestore
  Future<bool> isUsernameTaken(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // ✅ Sign up with email, password & username
  Future<fb_auth.UserCredential?> signUp({
    required String email,
    required String password,
    required String username,
    String? phoneNumber,
  }) async {
    // 🔍 Check if username exists
    if (await isUsernameTaken(username)) {
      throw Exception('Username already taken, please choose another one.');
    }

    // 📌 Register user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // 📝 Save user details to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'email': email.trim(),
      'username': username,
      'phoneNumber': phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update display name
    await userCredential.user?.updateDisplayName(username);

    // Initialize Stream Chat
    await initializeStreamClient(userCredential.user!.uid);

    return userCredential;
  }

  // ✅ Sign in with email & password
  Future<fb_auth.UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Try to reconnect existing client
    await initializeStreamClient(userCredential.user!.uid);
    return userCredential;
  }

  // ✅ Sign in with Google
  Future<fb_auth.User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final fb_auth.AuthCredential credential =
        fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final fb_auth.UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final fb_auth.User? user = userCredential.user;

    if (user != null) {
      // Try to reconnect existing client
      await initializeStreamClient(user.uid);
    }
    return user;
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _streamClient?.disconnectUser();
    await _auth.signOut();
    _streamClient = null;

    // Clear saved client
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientKey);
  }

  // ✅ Create a new chat channel
  Future<Channel> createChannel({
    required String channelId,
    required List<String> members,
    String? name,
    Map<String, dynamic>? extraData,
  }) async {
    if (_streamClient == null) {
      throw Exception('Stream client not initialized');
    }
    final channel = _streamClient!.channel(
      'messaging',
      id: channelId,
      extraData: {
        'name': name ?? 'New Chat',
        'members': members,
        ...?extraData,
      },
    );
    await channel.create();
    return channel;
  }

  // ✅ Get or create a direct message channel with another user
  Future<Channel> getOrCreateDirectMessageChannel(String otherUserId) async {
    if (_streamClient == null || _streamClient!.state.currentUser == null) {
      throw Exception('Stream Chat client not initialized');
    }

    final currentUserId = _streamClient!.state.currentUser!.id;
    final channelId = [currentUserId, otherUserId]..sort();
    final channel = _streamClient!.channel(
      'messaging',
      id: channelId.join('-'),
      extraData: {
        'members': [currentUserId, otherUserId],
        'type': 'direct_message',
      },
    );

    try {
      // Try to get existing channel
      final channelState = await channel.query();
      if (channelState.channel != null) {
        print("✅ Found existing channel: ${channel.id}");
        return channel;
      }
    } catch (e) {
      print("🔍 Channel not found, creating new one: ${channel.id}");
    }

    // Create new channel if it doesn't exist
    await channel.create();
    print("✅ Created new channel: ${channel.id}");
    return channel;
  }

  Future<bool> authenticateOnStartup(BuildContext? context) async {
    if (context == null) {
      print("❌ BuildContext is null. Skipping authentication.");
      return false; // Return false or handle as needed
    }

    final isPinEnabled = _settingsService.isPinLockEnabled;
    final isFingerprintEnabled = _settingsService.isFingerprintEnabled;

    if (isPinEnabled && isFingerprintEnabled) {
      return await _promptForAuthenticationChoice(context);
    } else if (isFingerprintEnabled) {
      return await _authenticateWithFingerprint();
    } else if (isPinEnabled) {
      return await _authenticateWithPin();
    }
    return true; // No authentication required
  }

  Future<bool> _promptForAuthenticationChoice(BuildContext context) async {
    // Use a Completer to wait for user input
    final completer = Completer<bool>();

    // Show a dialog to let the user choose
    showDialog(
      context: context, // Use the passed context
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Authentication Method'),
          content:
              const Text('Please select your preferred authentication method.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                completer.complete(await _authenticateWithFingerprint());
              },
              child: const Text('Fingerprint'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                completer.complete(await _authenticateWithPin());
              },
              child: const Text('PIN'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  Future<bool> _authenticateWithFingerprint() async {
    return await _localAuth.authenticate(
      localizedReason: 'Authenticate to access the app',
      options: const AuthenticationOptions(biometricOnly: true),
    );
  }

  Future<bool> _authenticateWithPin() async {
    final storage = FlutterSecureStorage();
    final storedPin = await storage.read(key: 'user_pin');

    if (storedPin == null) {
      print("❌ No PIN found in secure storage.");
      return false;
    }

    // Prompt user to enter their PIN (replace with actual UI implementation)
    final enteredPin = await _promptUserForPin();

    if (enteredPin == storedPin) {
      print("✅ PIN authentication successful.");
      return true;
    } else {
      print("❌ Incorrect PIN entered.");
      return false;
    }
  }

  Future<String?> _promptUserForPin() async {
    // Implement UI to prompt the user for their PIN
    // For now, return a placeholder value
    return '1234'; // Replace with actual user input
  }

  // ✅ Update username
  Future<void> updateUsername(String userId, String username) async {
    // Check if username exists
    if (await isUsernameTaken(username)) {
      throw Exception('Username already taken, please choose another one.');
    }

    // Update username in Firestore
    await _firestore.collection('users').doc(userId).update({
      'username': username,
    });

    // Update display name in Firebase Auth
    await _auth.currentUser?.updateDisplayName(username);
  }
}
