import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lingowise/services/auth_service.dart';

class ContactsService {
  final AuthService _authService = AuthService();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _users = [];
      return;
    }

    _isLoading = true;
    try {
      final client = _authService.streamClient;
      if (client == null) return;

      final response = await client.queryUsers(
        filter: Filter.or([
          Filter.autoComplete('name', query),
          Filter.autoComplete('id', query),
        ]),
      );

      _users = response.users.where((user) => user.id != client.state.currentUser!.id).toList();
    } catch (e) {
      print('Error searching users: $e');
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
