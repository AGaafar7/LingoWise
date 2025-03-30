import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class StreamChatService {
  static final StreamChatClient client = StreamChatClient(
    '8w7w6b93ktuu',
    logLevel: Level.INFO,
  );

  // ✅ Add this method to initialize the client
  static Future<StreamChatClient> initializeClient() async {
    return client; // Return the existing client instance
  }

  // 🔹 Get Stream Token (for development use only)
  static Future<String> getStreamToken(String userId) async {
    return client.devToken(userId).rawValue;
  }

  // 🔹 Create & connect a Stream Chat user
  static Future<void> createUser(String userId, String userName) async {
    final token = await getStreamToken(userId);

    await client.connectUser(
      User(id: userId, extraData: {'name': userName}),
      token,
    );

    final channel = client.channel(
      'messaging',
      id: userId,
      extraData: {
        'name': "$userName's Chat",
        'members': [userId],
      },
    );

    await channel.create();
  }
}
