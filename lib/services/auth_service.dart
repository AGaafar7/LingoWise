import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/tracked_stream_chat_client.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TrackedStreamChatClient? _streamClient;

  // ✅ Get current user
  fb_auth.User? get currentUser => _auth.currentUser;

  // ✅ Get Stream Chat client
  TrackedStreamChatClient? get streamClient => _streamClient;

  // ✅ Stream of auth state changes
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Initialize Stream Chat client for a user
  Future<void> initializeStreamClient(String userId) async {
    print("🔹 Initializing Stream Chat for user: $userId");

    final apikey = "8w7w6b93ktuu";
    final client = TrackedStreamChatClient(apikey, userId: userId);

    // Generate token
    final token = await client.createToken(userId);
    print("🔹 Stream Chat token generated: $token");

    // Connect user
    await client.connectUser(
      User(id: userId),
      token,
    );

    if (client.state.currentUser == null) {
      throw Exception("❌ Stream Chat authentication failed!");
    } else {
      print(
          "✅ Stream Chat user authenticated: ${client.state.currentUser!.id}");
    }

    _streamClient = client; // Save the client instance
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
      'username': username, // ✅ Store username in Firestore
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
    await initializeStreamClient(userCredential.user!.uid);
    return userCredential;
  }

  // ✅ Sign in with Google
  Future<fb_auth.User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User canceled login

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
      await initializeStreamClient(user.uid);
    }
    return user;
  }

  // ✅ Sign out
  Future<void> signOut() async {
    await _streamClient?.disconnectUser();
    await _auth.signOut();
    _streamClient = null;
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
    if (_streamClient == null || currentUser == null) {
      throw Exception('Stream client not initialized or user not logged in');
    }
    final channelId = [currentUser!.uid, otherUserId]..sort();
    final channel = _streamClient!.channel(
      'messaging',
      id: channelId.join('-'),
      extraData: {
        'members': [currentUser!.uid, otherUserId],
        'type': 'direct_message',
      },
    );
    await channel.create();
    return channel;
  }
}
