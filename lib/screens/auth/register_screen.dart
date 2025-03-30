import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

  // ✅ Check if the username exists
  Future<bool> _isUsernameTaken(String username) async {
    return await _authService.isUsernameTaken(username);
  }

  // ✅ Register with Email & Password
  Future<void> _registerWithEmail() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }

    final isTaken = await _isUsernameTaken(username);
    if (isTaken) {
      _showErrorDialog("Username is already taken. Please choose another one.");
      return;
    }

    try {
      final userCredential = await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (userCredential != null) {
        _navigateToMainScreen();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  // ✅ Register with Google
  Future<void> _registerWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _navigateToMainScreen();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  // ✅ Register with Phone (Send OTP)
  Future<void> _registerWithPhone() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showErrorDialog("Phone number cannot be empty.");
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        _navigateToMainScreen();
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorDialog("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // ✅ Verify OTP
  Future<void> _verifyOTP(String otp) async {
    if (_verificationId == null) {
      _showErrorDialog("No verification ID found. Please request a new OTP.");
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToMainScreen();
    } catch (e) {
      _showErrorDialog("OTP verification failed. Try again.");
    }
  }

  // ✅ Show Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ✅ Navigate to Main Screen
  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _registerWithEmail,
                child: const Text("Register with Email"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _registerWithGoogle,
                child: const Text("Register with Google"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              ElevatedButton(
                onPressed: _registerWithPhone,
                child: const Text("Register with Phone"),
              ),
              if (_verificationId != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: _otpController,
                      decoration: const InputDecoration(labelText: "Enter OTP"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _verifyOTP(_otpController.text.trim()),
                      child: const Text("Verify OTP"),
                    ),
                  ],
                ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
