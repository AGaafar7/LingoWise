import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  _ChatMainScreenState createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Channel channel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final client = StreamChat.of(context).client;
    channel = client.channel('messaging', id: 'test-channel');

    channel.watch();
  }

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;
    if (client.state.currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Handle null case
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.black87,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Morning",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "Ahmed Gaafar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(
                "AG",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.call), onPressed: () {}),
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Chats"),
              Tab(text: "Groups"),
              Tab(text: "Channels"),
            ],
            indicatorColor: Colors.white,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(client), // All chats
          _buildChatList(client), // Chats tab
          _buildEmptyState("No Groups yet"), // Empty Groups tab
          _buildEmptyState("No Channels yet"), // Empty Channels tab
        ],
      ),
    );
  }

  /// Builds the chat list using StreamChat
  Widget _buildChatList(StreamChatClient client) {
    return StreamChannelListView(
      controller: StreamChannelListController(
        client: client,
        filter: Filter.and([
          Filter.equal('type', 'messaging'), // Fetch only messaging channels
          Filter.in_('members', [client.state.currentUser!.id]),
        ]),
        channelStateSort: const [
          SortOption('last_message_at', direction: SortOption.DESC),
        ],
        presence: true, // Keeps track of online presence
        limit: 20, // Number of channels to fetch per page
      ),
      emptyBuilder: (_) => _buildEmptyState("No chats yet"),
      errorBuilder:
          (_, error) => Center(child: Text("Error: ${error.toString()}")),
      loadingBuilder: (_) => const Center(child: CircularProgressIndicator()),
      itemBuilder: (context, channels, index, defaultWidget) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ChatScreen(client: client, channel: channels[index]),
              ),
            );
          },
          child: defaultWidget,
        ); // Uses StreamChat’s default UI
      },
    );
  }

  /// Builds an empty state for Groups and Channels
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
