import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/tracked_stream_chat_client.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TrackedStreamChatClient? _streamClient;

  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Get Stream Chat client
  TrackedStreamChatClient? get streamClient => _streamClient;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Initialize Stream Chat client for a user
  Future<void> initializeStreamClient(String userId) async {
    _streamClient = TrackedStreamChatClient('8w7w6b93ktuu', userId: userId);
    
    // Generate a token for the user
    final token = await _streamClient!.createToken(userId);
    
    // Connect the user
    await _streamClient!.connectUser(
      User(id: userId),
      token,
    );
  }

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await userCredential.user?.updateDisplayName(name);

      // Initialize Stream Chat client
      await initializeStreamClient(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Initialize Stream Chat client
      await initializeStreamClient(userCredential.user!.uid);

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _streamClient?.disconnectUser();
    await _auth.signOut();
    _streamClient = null;
  }

  // Create a new channel
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

  // Get or create a direct message channel with another user
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
