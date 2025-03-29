import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:lingowise/screens/login_screen.dart';
import 'package:lingowise/screens/home_screen.dart';
import 'package:lingowise/screens/subscription_screen.dart';
import 'package:shared_preferences.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
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
                final streamClient = AuthService().streamClient;
                if (streamClient == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error: Stream Chat client not initialized'),
                    ),
                  );
                }

                return StreamChat(
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_subscription') ?? false;
  }
} 