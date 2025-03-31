import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'chat_screen.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final client = StreamChat.of(context).client;

      // 🔍 Listen for reconnections & authentication
      client.on(EventType.connectionRecovered).listen((event) {
        if (client.state.currentUser != null) {
          print(
              "✅ Stream Chat authenticated as: ${client.state.currentUser!.id}");
          _initializeChat(client);
          setState(() {});
        }
      });

      // ✅ Wait until authentication is confirmed
      final bool authenticated = await _waitForAuthentication(client);

      if (authenticated) {
        print(
            "✅ Stream Chat authenticated as: ${client.state.currentUser!.id}");
        await _initializeChat(client);
        setState(() {});
      } else {
        print("❌ Authentication timeout: Unable to get current user");
      }
    });
  }

  /// Waits for the Stream Chat user authentication (up to 10 seconds).
  Future<bool> _waitForAuthentication(StreamChatClient client) async {
    int retryCount = 0;
    while (client.state.currentUser == null && retryCount < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }
    return client.state.currentUser != null;
  }

  Future<void> _initializeChat(StreamChatClient client) async {
    channel = client.channel('messaging', id: 'test-channel');

    try {
      final channelState = await channel.query();
      if (channelState.channel == null) {
        print("🔄 Creating new channel...");
        await channel.create();
      } else {
        print("✅ Channel already exists!");
      }

      await channel.watch();
      print("🔍 Watching 'test-channel'");
    } catch (e) {
      print("❌ Error creating or watching channel: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context).client;

    if (client.state.currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildMainUI(client);
  }

  Widget _buildMainUI(StreamChatClient client) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.black87,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good Morning",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text("Ahmed Gaafar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text("AG",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
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
          _buildChatList(client),
          _buildChatList(client),
          _buildEmptyState("No Groups yet"),
          _buildEmptyState("No Channels yet"),
        ],
      ),
    );
  }

  Widget _buildChatList(StreamChatClient client) {
    return StreamChannelListView(
      controller: StreamChannelListController(
        client: client,
        filter: Filter.and([
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [client.state.currentUser!.id]),
        ]),
        channelStateSort: const [
          SortOption('last_message_at', direction: SortOption.DESC),
        ],
        presence: true,
        limit: 20,
      ),
      emptyBuilder: (_) => _buildEmptyState("No chats yet"),
      errorBuilder: (_, error) =>
          Center(child: Text("Error: \${error.toString()}")),
      loadingBuilder: (_) => const Center(child: CircularProgressIndicator()),
      itemBuilder: (context, channels, index, defaultWidget) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(channel: channels[index]),
              ),
            );
          },
          child: defaultWidget,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message,
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
