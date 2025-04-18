import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:lingowise/screens/main_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import 'package:lingowise/services/auth_service.dart' as auth;
import 'package:lingowise/screens/login_screen.dart';
import 'package:lingowise/screens/home_screen.dart';
import 'package:lingowise/screens/subscription_screen.dart';
import 'package:lingowise/screens/auth_failed_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  const AuthWrapper({super.key, required this.onLocaleChange});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = auth.AuthService();
  bool _isInitializing = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initializeStreamClient();
    _authenticateOnStartup();
  }

  Future<void> _initializeStreamClient() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final user = _authService.currentUser;
      if (user != null) {
        print(
            "🔹 Starting Stream Chat initialization in AuthWrapper for user: ${user.uid}");

        // Check if already initialized
        if (_authService.streamClient?.state.currentUser != null) {
          print(
              "✅ Stream Chat already initialized for user: ${_authService.streamClient?.state.currentUser?.id}");
          return;
        }

        await _authService.initializeStreamClient(user.uid);

        // Verify initialization
        if (_authService.streamClient?.state.currentUser == null) {
          print("❌ Stream Chat initialization failed - no current user");
        } else {
          print(
              "✅ Stream Chat initialized successfully for user: ${_authService.streamClient?.state.currentUser?.id}");
        }
      }
    } catch (e) {
      print("❌ Error initializing Stream Chat in AuthWrapper: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _authenticateOnStartup() async {
    final isAuthenticated = await _authService.authenticateOnStartup(context);
    if (!isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AuthenticationFailedScreen(
                  errorMessage: "Failed to authenticate",
                )),
      );
    } else {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<fb_auth.User?>(
      stream: _authService.authStateChanges.cast<fb_auth.User?>(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: _checkSubscriptionStatus(),
            builder: (context, subscriptionSnapshot) {
              if (subscriptionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (subscriptionSnapshot.data == true) {
                final streamClient = _authService.streamClient;
                if (streamClient == null ||
                    streamClient.state.currentUser == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error: Stream Chat client not initialized'),
                    ),
                  );
                }

                return stream.StreamChat(
                  client: streamClient,
                  child: MainScreen(onLocaleChange: widget.onLocaleChange),
                );
              }

              return SubscriptionScreen();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }

  Future<bool> _checkSubscriptionStatus() async {
    final prefsInstance = await prefs.SharedPreferences.getInstance();
    return prefsInstance.getBool('has_subscription') ?? false;
  }
}
