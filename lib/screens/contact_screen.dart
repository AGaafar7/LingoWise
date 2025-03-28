import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _requestPermissionAndLoadContacts() async {
    if (await Permission.contacts.request().isGranted) {
      _loadContacts();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadContacts() async {
    List<Contact> contacts = await FlutterContacts.getContacts(
      withProperties: true,
    );
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
      _isLoading = false;
    });
  }

  void _filterContacts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts =
          _contacts.where((contact) {
            return contact.displayName.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search Contacts',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredContacts.isEmpty
                            ? const Center(child: Text('No contacts found'))
                            : ListView.builder(
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                return ListTile(
                                  title: Text(contact.displayName),
                                  subtitle: Text(
                                    contact.phones.isNotEmpty
                                        ? contact.phones.first.number
                                        : 'No phone number',
                                  ),
                                  leading:
                                      contact.photo == null
                                          ? CircleAvatar(
                                            child: Text(contact.displayName[0]),
                                          )
                                          : CircleAvatar(
                                            backgroundImage: MemoryImage(
                                              contact.photo!,
                                            ),
                                          ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
