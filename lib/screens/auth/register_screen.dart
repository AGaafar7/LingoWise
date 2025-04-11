import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const RegisterScreen({super.key, required this.onLocaleChange});

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
  bool _isLoading = false;

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

    setState(() => _isLoading = true);
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Register with Google
  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Check if username is needed
        if (user.displayName == null || user.displayName!.isEmpty) {
          _showUsernameDialog(user.uid);
        } else {
          _navigateToMainScreen();
        }
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ Register with Phone (Send OTP)
  Future<void> _registerWithPhone() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showErrorDialog("Phone number cannot be empty.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential.user != null) {
            _showUsernameDialog(userCredential.user!.uid);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorDialog("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
          _showOTPDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      _showErrorDialog(e.toString());
      setState(() => _isLoading = false);
    }
  }

  // ✅ Verify OTP
  Future<void> _verifyOTP(String otp) async {
    if (_verificationId == null) {
      _showErrorDialog("No verification ID found. Please request a new OTP.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        _showUsernameDialog(userCredential.user!.uid);
      }
    } catch (e) {
      _showErrorDialog("OTP verification failed. Try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showUsernameDialog(String userId) {
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Choose Username"),
        content: TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            hintText: "Enter your username",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              if (username.isEmpty) {
                _showErrorDialog("Username cannot be empty");
                return;
              }

              final isTaken = await _isUsernameTaken(username);
              if (isTaken) {
                _showErrorDialog("Username is already taken");
                return;
              }

              Navigator.pop(context);
              await _authService.updateUsername(userId, username);
              _navigateToMainScreen();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showOTPDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter OTP"),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter the 6-digit code",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyOTP(_otpController.text);
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
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
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          onLocaleChange: widget.onLocaleChange,
        ),
      ),
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
                onPressed: _isLoading ? null : _registerWithEmail,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register with Email"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerWithGoogle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register with Google"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerWithPhone,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Register with Phone"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        onLocaleChange: widget.onLocaleChange,
                      ),
                    ),
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
