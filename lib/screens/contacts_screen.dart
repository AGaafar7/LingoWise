import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat;
import 'package:lingowise/services/contacts_service.dart' as contacts_service;
import 'package:lingowise/screens/chat_screen.dart';
import 'package:lingowise/services/auth_service.dart' as auth_service;

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final contacts_service.ContactsService _contactsService = contacts_service.ContactsService();
  final auth_service.AuthService _authService = auth_service.AuthService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChatAndLoadUsers();
  }

  Future<void> _initializeChatAndLoadUsers() async {
    print("🔹 Initializing Stream Chat and loading contacts...");

    // Initialize Stream Chat client
    await _authService.initializeStreamClient(_authService.currentUser!.uid);

    // Load contacts (could be from a network or local storage, like `flutter_contacts`)
    await _contactsService.loadDeviceContacts();

    // Debugging: Check the length of contacts
    print("🧑‍🤝‍🧑 Contacts loaded: ${_contactsService.deviceContacts.length}");

    // Load registered users
    await _contactsService.loadDeviceContacts();

    // Debugging: Check the length of registered users
    print("🧑‍🤝‍🧑 Registered users loaded: ${_contactsService.registeredUsers.length}");

    // Update UI if mounted
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUserTap(stream_chat.User user) async {
    print("🖱️ User tapped: ${user.id}");

    setState(() => _isLoading = true);

    try {
      final channel =
          await _contactsService.createDirectMessageChannel(user.id);
      if (channel == null) {
        print("❌ Failed to create or fetch chat channel");
        return;
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => stream_chat.StreamChannel(
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

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if users are loaded
    if (_contactsService.registeredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No users found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeChatAndLoadUsers,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _contactsService.registeredUsers.length,
      itemBuilder: (context, index) {
        final user = _contactsService.registeredUsers[index];
        return GestureDetector(
          onTap: () {
            print("✅ GestureDetector tapped on ${user.id}");
            _handleUserTap(user);
          },
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name.isNotEmpty ? user.name[0] : '?'),
            ),
            title: Text(user.name.isNotEmpty ? user.name : 'Unknown'),
            subtitle: Text(user.id),
            trailing: const Icon(Icons.chat),
          ),
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
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }
}
