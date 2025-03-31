import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lingowise/services/auth_service.dart';

class ContactsService {
  final AuthService _authService = AuthService();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadAllUsers() async {
    _isLoading = true;
    try {
      final client = _authService.streamClient;
      if (client == null) {
        print("❌ Stream Chat client is null in loadAllUsers");
        return;
      }

      print("🔍 Loading all users...");
      final response = await client.queryUsers(
        filter: Filter.and([
          Filter.notEqual('id', client.state.currentUser!.id),
        ]),
      );

      _users = response.users;
      print("✅ Loaded ${_users.length} users");
    } catch (e) {
      print('❌ Error loading users: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> searchUsers(String query) async {
    _isLoading = true;
    try {
      final client = _authService.streamClient;
      if (client == null) {
        print("❌ Stream Chat client is null in searchUsers");
        return;
      }

      if (query.isEmpty) {
        print("🔍 Empty query, loading all users");
        await loadAllUsers();
        return;
      }

      print("🔍 Searching users with query: $query");
      final response = await client.queryUsers(
        filter: Filter.and([
          Filter.notEqual('id', client.state.currentUser!.id),
          Filter.or([
            Filter.autoComplete('name', query),
            Filter.autoComplete('id', query),
          ]),
        ]),
      );

      _users = response.users;
      print("✅ Found ${_users.length} users matching query");
    } catch (e) {
      print('❌ Error searching users: $e');
    } finally {
      _isLoading = false;
    }
  }

  Future<void> sendWhatsAppInvite(String phoneNumber) async {
    const message = 'Join me on LingoWise! Download the app here: [App Store/Play Store Link]';
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    }
  }

  Future<void> sendEmailInvite(String email) async {
    const subject = 'Join me on LingoWise!';
    const body = 'Hi! I would like you to join me on LingoWise. You can download the app here: [App Store/Play Store Link]';
    final mailtoUrl = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    
    if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
      await launchUrl(Uri.parse(mailtoUrl));
    }
  }

  Future<Channel?> createDirectMessageChannel(String userId) async {
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
