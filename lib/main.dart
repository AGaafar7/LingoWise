import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/theme/app_theme.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final client = StreamChatClient('8w7w6b93ktuu', logLevel: Level.INFO);
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: client,
      child: MaterialApp(
        title: 'LingoWise',
        theme: appTheme,

        themeMode: ThemeMode.system,

        routes: {'/': (context) => LoginScreen()},
      ),
    );
  }
}
