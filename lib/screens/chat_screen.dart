import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatScreen extends StatelessWidget {
  final Channel channel; // Add a required channel parameter

  const ChatScreen({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: channel, // Provide the channel here
      child: Scaffold(
        appBar: AppBar(
          title: StreamChannelName(
            channel: channel,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => StreamChannelInfo(
                    channel: channel,
                  ),
                );
              },
            ),
          ],
        ),
        body: const Column(
          children: [
            Expanded(
              child: StreamMessageListView(),
            ),
            StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}
