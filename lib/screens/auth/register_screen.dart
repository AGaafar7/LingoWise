import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _verificationId;

  // ✅ Register with Email & Password
  Future<void> _registerWithEmail() async {
    final user = await _authService.registerWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (user != null) _navigateToMainScreen();
  }

  // ✅ Register with Google
  Future<void> _registerWithGoogle() async {
    final user = await _authService.registerWithGoogle();
    if (user != null) _navigateToMainScreen();
  }

  // ✅ Register with Phone Number (OTP)
  Future<void> _registerWithPhone() async {
    _authService.registerWithPhone(_phoneController.text, (verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
    });
  }

  // ✅ Verify OTP Code
  Future<void> _verifyOTP(String otp) async {
    if (_verificationId == null) return;
    final user = await _authService.verifyOTP(_verificationId!, otp);
    if (user != null) _navigateToMainScreen();
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            _verificationId != null
                ? TextField(
                  decoration: const InputDecoration(labelText: "Enter OTP"),
                  onSubmitted: _verifyOTP,
                )
                : Container(),
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
    );
  }
}
