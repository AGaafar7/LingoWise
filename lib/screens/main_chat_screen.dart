import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
import 'chat_screen.dart';
import 'package:lingowise/services/auth_service.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  _ChatMainScreenState createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  stream.Channel? channel;
  bool _isInitialized = false;
  final _authService = AuthService();
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;

    try {
      // Get current Firebase user
      final firebaseUser = _authService.currentUser;
      if (firebaseUser == null) {
        print("❌ No Firebase user found");
        return;
      }

      // Get or initialize Stream Chat client
      final client = _authService.streamClient;
      if (client == null) {
        print("🔹 Initializing Stream Chat client for user: ${firebaseUser.uid}");
        await _authService.initializeStreamClient(firebaseUser.uid);
      }

      // Get the updated client
      final updatedClient = _authService.streamClient;
      if (updatedClient == null || updatedClient.state.currentUser == null) {
        print("❌ Stream Chat client not initialized");
        return;
      }

      print("✅ Stream Chat client ready: ${updatedClient.state.currentUser!.id}");
      
      // Set up the channel
      await _setupChannel(updatedClient);
      setState(() => _isInitialized = true);
    } catch (e) {
      print("❌ Error during initialization: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _setupChannel(stream.StreamChatClient client) async {
    try {
      // Create a unique channel ID based on the user's ID
      final channelId = 'user-${client.state.currentUser!.id}';
      channel = client.channel('messaging', id: channelId);
      
      final channelState = await channel!.query();
      if (channelState.channel == null) {
        print("🔄 Creating new channel for user: ${client.state.currentUser!.id}");
        await channel!.create();
      } else {
        print("✅ Channel already exists for user: ${client.state.currentUser!.id}");
      }

      if (!channel!.state!.isUpToDate) {
        await channel!.watch();
        print("🔍 Watching channel: $channelId");
      }
    } catch (e) {
      print("❌ Error setting up channel: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _authService.streamClient;

    if (!_isInitialized || client == null || client.state.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing chat...'),
            ],
          ),
        ),
      );
    }

    return _buildMainUI(client);
  }

  Widget _buildMainUI(stream.StreamChatClient client) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.black87,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Good Morning",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                client.state.currentUser?.name ?? "User",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(
                client.state.currentUser?.name.substring(0, 2).toUpperCase() ?? "U",
                style: const TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildChatList(stream.StreamChatClient client) {
    return stream.StreamChannelListView(
      controller: stream.StreamChannelListController(
        client: client,
        filter: stream.Filter.and([
          stream.Filter.equal('type', 'messaging'),
          stream.Filter.in_('members', [client.state.currentUser!.id]),
        ]),
        channelStateSort: const [
          stream.SortOption('last_message_at', direction: stream.SortOption.DESC),
        ],
        presence: true,
        limit: 20,
      ),
      emptyBuilder: (_) => _buildEmptyState("No chats yet"),
      errorBuilder: (_, error) => Center(
        child: Text("Error: ${error.toString()}"),
      ),
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
          Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}
