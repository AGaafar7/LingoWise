import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lingowise/screens/screens.dart';

class LoginScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const LoginScreen({super.key, required this.onLocaleChange});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // 🔹 Form validation key

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserLoggedIn();
    });
  }

  void _checkUserLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_auth.currentUser != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(onLocaleChange: widget.onLocaleChange)),
      );
    }
  }

  // ✅ Login with Email & Password
  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return; // 🔹 Validate inputs

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(onLocaleChange: widget.onLocaleChange)),
      );
    } catch (e) {
      _showErrorSnackBar(_getFriendlyErrorMessage(e));
    }
  }

  // ✅ Login with Google
  Future<void> _loginWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // 🔹 Prevents cached issues
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(onLocaleChange: widget.onLocaleChange)),
      );
    } catch (e) {
      _showErrorSnackBar(_getFriendlyErrorMessage(e));
    }
  }

  // ✅ Friendly Error Messages
  String _getFriendlyErrorMessage(dynamic error) {
    String errorMessage = "Something went wrong. Please try again.";

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email address format.";
          break;
        case 'network-request-failed':
          errorMessage = "No internet connection.";
          break;
      }
    }

    return errorMessage;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loginWithEmail,
                child: const Text("Login with Email"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loginWithGoogle,
                child: const Text("Login with Google"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RegisterScreen(onLocaleChange: widget.onLocaleChange),
                    ),
                  );
                },
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
