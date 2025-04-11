import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lingowise/screens/screens.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const PhoneVerificationScreen({super.key, required this.onLocaleChange});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? _verificationId;
  bool isLoading = false;
  bool isVerifying = false;

  // ✅ Regex for International Phone Number Validation
  final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{6,14}$');

  // 🔵 Send OTP
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return; // ✅ Validate input first

    setState(() => isLoading = true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToMainScreen();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            isLoading = false;
          });
          _showSnackBar("OTP Sent! Please check your phone.");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _showSnackBar(e.toString());
    }
    setState(() => isLoading = false);
  }

  // 🔵 Verify OTP
  Future<void> _verifyOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      _showSnackBar("Please enter the OTP.");
      return;
    }

    setState(() => isVerifying = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _navigateToMainScreen();
    } catch (e) {
      _showSnackBar("Invalid OTP. Please try again.");
    }
    setState(() => isVerifying = false);
  }

  // ✅ Navigate to MainScreen
  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(onLocaleChange: widget.onLocaleChange),
      ),
    );
  }

  // ✅ Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Phone Number Input with Validation
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number (e.g., +1234567890)",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number.";
                  }
                  if (!_phoneRegex.hasMatch(value)) {
                    return "Enter a valid phone number with country code.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // 🔹 Send OTP Button with Loading Indicator
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _sendOTP,
                    child: const Text("Send OTP"),
                  ),

              const SizedBox(height: 10),

              // 🔹 OTP Input
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: "Enter OTP"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              // 🔹 Verify OTP Button with Loading Indicator
              isVerifying
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _verifyOTP,
                    child: const Text("Verify OTP"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
