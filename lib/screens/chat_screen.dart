import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/settings_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
    
    return Scaffold(
      appBar: AppBar(
        title: StreamChannelName(),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StreamChannelInfo(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(
              showTypingIndicator: settingsService.getTypingIndicatorEnabled(),
              showReadReceipts: settingsService.getReadReceiptsEnabled(),
            ),
          ),
          const StreamMessageInput(),
        ],
      ),
    );
  }
}
