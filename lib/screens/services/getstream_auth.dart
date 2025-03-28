import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AuthService {
  final StreamChatClient client;

  AuthService(this.client);

  Future<String> getStreamToken(String userId) async {
    final client = StreamChatClient('8w7w6b93ktuu', logLevel: Level.INFO);
    return client.devToken(userId).rawValue;
  }

  Future<void> connectUser() async {
    final fb_auth.User? firebaseUser =
        fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      final token = await getStreamToken(firebaseUser.uid);
      await client.connectUser(
        User(
          id: firebaseUser.uid,
          extraData: {'name': firebaseUser.displayName ?? 'User'},
        ),
        token,
      );
    }
  }
}
