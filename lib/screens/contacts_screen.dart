import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/contacts_service.dart';
import 'package:lingowise/screens/chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _contactsService = ContactsService();
  final _searchController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _showInviteDialog = false;

  @override
  void dispose() {
    _searchController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showInviteOptions() {
    setState(() => _showInviteDialog = true);
  }

  void _hideInviteOptions() {
    setState(() => _showInviteDialog = false);
  }

  Widget _buildUserList() {
    if (_contactsService.isLoading) {
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
              onPressed: _showInviteOptions,
              child: const Text('Invite Friends'),
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
            child: Text(user.name[0] ?? user.id[0]),
          ),
          title: Text(user.name ?? user.id),
          subtitle: Text(user.id),
          trailing: IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () async {
              final channel =
                  await _contactsService.createDirectMessageChannel(user.id);
              if (channel != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StreamChannel(
                      channel: channel,
                      child: ChatScreen(
                        channel: channel,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildInviteDialog() {
    return AlertDialog(
      title: const Text('Invite Friends'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number (with country code)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _hideInviteOptions,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_phoneController.text.isNotEmpty) {
              await _contactsService.sendWhatsAppInvite(_phoneController.text);
            }
            if (_emailController.text.isNotEmpty) {
              await _contactsService.sendEmailInvite(_emailController.text);
            }
            _phoneController.clear();
            _emailController.clear();
            _hideInviteOptions();
          },
          child: const Text('Send Invites'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showInviteOptions,
          ),
        ],
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
                        },
                      )
                    : null,
              ),
              onChanged: (value) => _contactsService.searchUsers(value),
            ),
          ),
          Expanded(child: _buildUserList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInviteOptions,
        child: const Icon(Icons.person_add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
