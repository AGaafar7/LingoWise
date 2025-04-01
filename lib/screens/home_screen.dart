import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:lingowise/services/settings_service.dart';
import 'package:lingowise/screens/settings_screen.dart';
import 'package:lingowise/screens/contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _groupNameController = TextEditingController();
  final _authService = AuthService();
  final _settingsService = SettingsService();
  late TabController _tabController;
  bool _isLoading = true;
  List<Channel> _groups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGroups();
    _applyChatSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _applyChatSettings() async {
    final client = _authService.streamClient;
    if (client == null) return;

    if (!_settingsService.getOnlineStatusVisible()) {
      await client.disconnectUser(flushChatPersistence: false);
    } else {
      await client.connectUser(
        User(id: client.state.currentUser!.id),
        client.devToken(client.state.currentUser!.id).rawValue,
      );
    }

    if (!_settingsService.getTypingIndicatorEnabled()) {
      for (var channel in client.state.channels.values) {
        channel.state?.typingEvents.clear();
      }
    }

    if (!_settingsService.getReadReceiptsEnabled()) {
      for (var channel in client.state.channels.values) {
        channel.state?.read.clear();
      }
    }
  }

  Future<void> _loadGroups() async {
    try {
      final client = _authService.streamClient;
      if (client == null) return;

      final groupsStream = client.queryChannels(
        state: true,
        filter: Filter.and([
          Filter.in_('members', [client.state.currentUser!.id]),
          Filter.equal('type', 'group'),
        ]),
      );

      groupsStream.listen((channels) {
        setState(() {
          _groups = channels;
          _isLoading = false;
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading groups: $e')),
        );
      }
    }
  }

  Future<void> _createNewGroup() async {
    if (_groupNameController.text.isEmpty) return;

    try {
      final group = await _authService.createChannel(
        channelId: DateTime.now().millisecondsSinceEpoch.toString(),
        members: [_authService.currentUser!.uid],
        name: _groupNameController.text,
        extraData: {'type': 'group'},
      );

      setState(() {
        _groups.add(group);
      });

      _groupNameController.clear();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Group'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createNewGroup,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No groups yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreateGroupDialog,
              child: const Text('Create Group'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(group.name?[0] ?? '?'),
          ),
          title: Text(group.name ?? 'Unnamed Group'),
          subtitle: Text(group.lastMessageAt?.toString() ?? 'No messages'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupChatScreen(channel: group),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoWise Chat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Groups'),
            Tab(text: 'Direct Messages'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ).then((_) => _applyChatSettings());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupList(),
          const DirectMessagesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupChatScreen extends StatelessWidget {
  final Channel channel;

  const GroupChatScreen({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamChannelName(channel: channel),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StreamChannelInfo(channel: channel),
              );
            },
          ),
        ],
      ),
      body: StreamChat(
        client: channel.client,
        child: StreamChannel(
          channel: channel,
          child: const Column(
            children: [
              Expanded(
                child: StreamMessageListView(),
              ),
              StreamMessageInput(),
            ],
          ),
        ),
      ),
    );
  }
}

class DirectMessagesTab extends StatelessWidget {
  const DirectMessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ContactsScreen();
  }
}
