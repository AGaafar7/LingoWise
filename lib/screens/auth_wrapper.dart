import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'package:shared_preferences/shared_preferences.dart' as prefs;
import 'package:lingowise/services/auth_service.dart' as auth;
import 'package:lingowise/screens/login_screen.dart';
import 'package:lingowise/screens/home_screen.dart';
import 'package:lingowise/screens/subscription_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = auth.AuthService();

  @override
  void initState() {
    super.initState();
    _initializeStreamClient();
  }

  Future<void> _initializeStreamClient() async {
    await _authService.initializeStreamClient();
  }

  @override
  Widget build(BuildContext context) {
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
              if (subscriptionSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (subscriptionSnapshot.data == true) {
                final streamClient = _authService.streamClient;
                if (streamClient == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error: Stream Chat client not initialized'),
                    ),
                  );
                }

                return stream.StreamChat(
                  client: streamClient,
                  child: const HomeScreen(),
                );
              }

              return const SubscriptionScreen();
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
