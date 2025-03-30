import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lingowise/screens/services/stream_chat_service.dart' as stream;
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat;

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  stream_chat.StreamChatClient? _streamClient;

  // Expose auth state changes with proper type
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges().map((user) => user);

  // Expose stream client
  stream_chat.StreamChatClient? get streamClient => _streamClient;

  // Initialize stream client
  Future<void> initializeStreamClient() async {
    _streamClient = await stream.StreamChatService.initializeClient();
  }

  // 🔹 Get current user
  fb_auth.User? getCurrentUser() => _auth.currentUser;

  // 🔹 Register with Email & Password
  Future<fb_auth.User?> registerWithEmail(String email, String password) async {
    try {
      fb_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      fb_auth.User? user = userCredential.user;

      if (user != null) {
        await stream.StreamChatService.createUser(user.uid, user.email ?? "User");
      }

      return user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  // 🔹 Sign in with Email & Password
  Future<fb_auth.User?> signInWithEmail(String email, String password) async {
    try {
      fb_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      fb_auth.User? user = userCredential.user;

      if (user != null) {
        await stream.StreamChatService.createUser(user.uid, user.email ?? "User");
      }

      return user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // 🔹 Register with Google
  Future<fb_auth.User?> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final fb_auth.AuthCredential credential = fb_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      fb_auth.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      fb_auth.User? user = userCredential.user;

      if (user != null) {
        await stream.StreamChatService.createUser(user.uid, user.email ?? "User");
      }

      return user;
    } catch (e) {
      print("Error registering with Google: $e");
      return null;
    }
  }

  // 🔹 Register with Phone Number (OTP)
  Future<void> registerWithPhone(
    String phoneNumber,
    Function(String verificationId) codeSentCallback,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.trim(),
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          print("Phone verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSentCallback(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto retrieval timeout");
        },
      );
    } catch (e) {
      print("Error registering with phone: $e");
    }
  }

  // 🔹 Verify OTP and Sign in
  Future<fb_auth.User?> verifyOTP(String verificationId, String otp) async {
    try {
      final fb_auth.AuthCredential credential = fb_auth
          .PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      fb_auth.UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      fb_auth.User? user = userCredential.user;

      if (user != null) {
        await stream.StreamChatService.createUser(
          user.uid,
          user.phoneNumber ?? "User",
        );
      }

      return user;
    } catch (e) {
      print("Error verifying OTP: $e");
      return null;
    }
  }

  // 🔹 Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
