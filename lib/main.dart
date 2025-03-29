import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/theme/app_theme.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final client = StreamChatClient('8w7w6b93ktuu', logLevel: Level.INFO);

  String devToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYWdhYWZhciJ9.JLPBkRWS-AGoSSvt5OghIebXtO1IbQe9_pgItk8GnUw";
  await client.connectUser(
    User(role: 'admin', id: 'agaafar', name: 'agaafar'),
    devToken,
  );
  await client.updateUser(User(id: 'agaafar', extraData: {'role': 'admin'}));

  final channel = client.channel(
    'messaging',
    id: 'messaging',
    extraData: {
      'name': 'New Chat',
      'members': ['agaafar'],
    },
  );
  await channel.create();

  runApp(MyApp(client: client, channel: channel));
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  final Channel channel;

  const MyApp({super.key, required this.client, required this.channel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoWise',
      theme: appTheme,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [Locale('en', 'US')],
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => StreamChat(client: client, child: AuthWrapper()),
      },
    );
  }
}
