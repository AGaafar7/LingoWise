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
  final contacts_service.ContactsService _contactsService =
      contacts_service.ContactsService();
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
    print(
        "🧑‍🤝‍🧑 Contacts loaded: ${_contactsService.deviceContacts.length}");

    // Load registered users
    await _contactsService.loadDeviceContacts();

    // Debugging: Check the length of registered users
    print(
        "🧑‍🤝‍🧑 Registered users loaded: ${_contactsService.registeredUsers.length}");

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

    return ListView(
      children: [
        // Section for Direct Chat
        if (_contactsService.registeredUsers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Direct Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._contactsService.registeredUsers.map((user) {
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
          }).toList(),
        ],

        // Section for All Contacts
        if (_contactsService.deviceContacts.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'All Contacts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ..._contactsService.deviceContacts.map((contact) {
            final isRegistered = _contactsService.isContactRegistered(contact);
            return ListTile(
              leading: CircleAvatar(
                child: Text(contact.displayName.isNotEmpty
                    ? contact.displayName[0]
                    : '?'),
              ),
              title: Text(contact.displayName.isNotEmpty
                  ? contact.displayName
                  : 'Unknown'),
              subtitle: Text(isRegistered ? 'Registered' : 'Not Registered'),
              trailing: isRegistered
                  ? const Icon(Icons.chat, color: Colors.green)
                  : const Icon(Icons.person_add, color: Colors.grey),
              onTap: isRegistered
                  ? () {
                      final user =
                          _contactsService.getRegisteredUserForContact(contact);
                      if (user != null) {
                        _handleUserTap(user);
                      }
                    }
                  : () async {
                      final email = contact.emails.isNotEmpty
                          ? contact.emails.first.address
                          : null;
                      if (email != null) {
                        await _contactsService.sendEmailInvite(email);
                      } else {
                        // Show dialog to manually enter email address
                        await _contactsService.showEmailInviteDialog(context);
                      }
                    },
            );
          }).toList(),
        ],
      ],
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
