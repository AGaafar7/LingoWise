import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream_chat;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:lingowise/services/auth_service.dart' as auth_service;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;

class ContactsService {
  final auth_service.AuthService _authService = auth_service.AuthService();
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  List<flutter_contacts.Contact> _deviceContacts = [];
  List<stream_chat.User> _registeredUsers = [];
  bool _isLoading = false;

  List<flutter_contacts.Contact> get deviceContacts => _deviceContacts;
  List<stream_chat.User> get registeredUsers => _registeredUsers;
  bool get isLoading => _isLoading;

  Future<void> loadDeviceContacts() async {
    _isLoading = true;
    try {
      // Request contacts permission
      final permission = await permission_handler.Permission.contacts.request();
      if (permission.isGranted) {
        final contacts = await flutter_contacts.FlutterContacts.getContacts();
        _deviceContacts = contacts;
        print("✅ Loaded ${_deviceContacts.length} device contacts");

        // Check which contacts are registered users
        await _checkRegisteredUsers();
      } else {
        print("❌ Contacts permission denied");
      }
    } catch (e) {
      print('❌ Error loading contacts: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _checkRegisteredUsers() async {
    try {
      // Get all registered users from Firestore
      final usersSnapshot = await _firestore.collection('users').get();
      final registeredEmails = usersSnapshot.docs
          .map((doc) => doc.data()['email'] as String)
          .toList();

      // Get Stream Chat users
      final client = _authService.streamClient;
      if (client == null) {
        print("❌ Stream Chat client is null");
        return;
      }

      final response = await client.queryUsers(
        filter: stream_chat.Filter.and([
          stream_chat.Filter.notEqual('id', client.state.currentUser!.id),
        ]),
      );

      _registeredUsers = response.users;
      print("✅ Found ${_registeredUsers.length} registered users");
    } catch (e) {
      print('❌ Error checking registered users: $e');
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await _checkRegisteredUsers(); // Reload all users if search is cleared
      return;
    }

    // Filter the registered users based on the query (search by name)
    _registeredUsers = _registeredUsers.where((user) {
      final userName = user.name?.toLowerCase() ?? '';
      return userName.contains(query.toLowerCase());
    }).toList();
  }

  bool isContactRegistered(flutter_contacts.Contact contact) {
    // Check if contact's email or phone is registered
    return _registeredUsers.any((user) {
      final userEmail = user.extraData?['email'] as String?;
      final userPhone = user.extraData?['phoneNumber'] as String?;

      // Check for non-null email and phone
      final isEmailMatch =
          contact.emails?.any((email) => email.address == userEmail) ?? false;
      final isPhoneMatch =
          contact.phones?.any((phone) => phone.number == userPhone) ?? false;

      return isEmailMatch || isPhoneMatch;
    });
  }

  stream_chat.User? getRegisteredUserForContact(
      flutter_contacts.Contact contact) {
    try {
      // Search for the registered user based on the contact's email or phone
      return _registeredUsers.firstWhere(
        (user) {
          final userEmail = user.extraData?['email'] as String?;
          final userPhone = user.extraData?['phoneNumber'] as String?;

          // Check for email and phone matches
          final isEmailMatch =
              contact.emails?.any((email) => email.address == userEmail) ??
                  false;
          final isPhoneMatch =
              contact.phones?.any((phone) => phone.number == userPhone) ??
                  false;

          return isEmailMatch || isPhoneMatch;
        },
        // Return null if no match
      );
    } catch (e) {
      print('❌ Error retrieving registered user for contact: $e');
      return null; // Return null in case of any error
    }
  }

  Future<void> sendWhatsAppInvite(String phoneNumber) async {
    const message =
        'Join me on LingoWise! Download the app here: [App Store/Play Store Link]';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    if (await url_launcher.canLaunchUrl(Uri.parse(whatsappUrl))) {
      await url_launcher.launchUrl(Uri.parse(whatsappUrl));
    }
  }

  Future<void> sendEmailInvite(String email) async {
    const subject = 'Join me on LingoWise!';
    const body =
        'Hi! I would like you to join me on LingoWise. You can download the app here: [App Store/Play Store Link]';
    final mailtoUrl =
        'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    if (await url_launcher.canLaunchUrl(Uri.parse(mailtoUrl))) {
      await url_launcher.launchUrl(Uri.parse(mailtoUrl));
    }
  }

  Future<stream_chat.Channel?> createDirectMessageChannel(String userId) async {
    try {
      final client = _authService.streamClient;
      if (client == null) return null;

      final channelId = [client.state.currentUser!.id, userId]..sort();
      final channel = client.channel(
        'messaging',
        id: channelId.join('-'),
        extraData: {
          'members': [client.state.currentUser!.id, userId],
          'type': 'direct_message',
        },
      );

      await channel.create();
      return channel;
    } catch (e) {
      print('Error creating direct message channel: $e');
      return null;
    }
  }
}
