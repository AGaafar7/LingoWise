import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/contacts_service.dart';
import 'package:lingowise/screens/chat_screen.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsService _contactsService = ContactsService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChatAndLoadUsers();
  }

  // Initializes the Stream client and loads the users
  Future<void> _initializeChatAndLoadUsers() async {
    print("🔹 Initializing Stream Chat and loading contacts...");

    await _authService.initializeStreamClient(_authService.currentUser?.uid);

    await _contactsService.loadAllUsers();

    if (mounted) {
      setState(() {});
    }
  }

  // Handle tap on user to create or fetch chat channel
  Future<void> _handleUserTap(User user) async {
    print("🔍 User tapped: ${user.id}");
    
    setState(() => _isLoading = true);

    try {
      final channel = await _contactsService.createDirectMessageChannel(user.id);

      if (channel == null) {
        print("❌ Failed to create or fetch chat channel");
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamChannel(
              channel: channel,
              child: ChatScreen(channel: channel),
            ),
          ),
        );
      }
    } catch (e) {
      print("❌ Error starting chat: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Builds the list of users or handles UI when there are no users or the app is loading
  Widget _buildUserList() {
    print("📌 Rendering user list with ${_contactsService.users.length} users");

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contactsService.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No users found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                print("🔄 Refreshing users...");
                await _initializeChatAndLoadUsers();
                setState(() {});
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
  itemCount: _contactsService.users.length,
  itemBuilder: (context, index) {
    final user = _contactsService.users[index];

    return ListTile(
      leading: CircleAvatar(
        child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
      ),
      title: Text(user.name.isNotEmpty ? user.name : 'Unknown'),
      subtitle: Text(user.id),
      trailing: const Icon(Icons.chat),
      onTap: () => _handleUserTap(user),  // Directly handle tap here
    );
  },
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: Column(
        children: [
          // Search bar to filter users
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _contactsService.searchUsers('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) async {
                await _contactsService.searchUsers(value);
                setState(() {});
              },
            ),
          ),

          // Displaying the user list or loading state
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
