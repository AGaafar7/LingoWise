import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatScreen extends StatelessWidget {
  final StreamChatClient client;
  final Channel channel;

  const ChatScreen({super.key, required this.client, required this.channel});

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: channel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: StreamBuilder<ChannelState>(
            stream: channel.state?.channelStateStream,
            builder: (context, snapshot) {
              final name = channel.extraData['name'] ?? 'Chat';
              return Text(name.toString());
            },
          ),
          actions: [
            IconButton(icon: const Icon(Icons.call), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: StreamMessageListView()),
            const Divider(height: 1),
            const StreamMessageInput(),
          ],
        ),
      ),
    );
  }
}
