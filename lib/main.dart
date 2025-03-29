import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/theme/app_theme.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:lingowise/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final client = StreamChatClient('8w7w6b93ktuu', logLevel: Level.INFO);

  try {
    // Stream Chat User Initialization
    String devToken =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYWdhYWZhciJ9.JLPBkRWS-AGoSSvt5OghIebXtO1IbQe9_pgItk8GnUw";

    await client.connectUser(
      User(id: 'agaafar', name: 'agaafar', role: 'admin'),
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
  } catch (e) {
    debugPrint("Error initializing StreamChat: $e");
  }
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;
  final Channel channel;

  const MyApp({super.key, required this.client, required this.channel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Provides theme management
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LingoWise',
            theme: appThemeLight,
            darkTheme: appThemeDark,
            themeMode: themeProvider.themeMode, // Dynamic theme switching
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en', 'US')],
            routes: {
              '/':
                  (context) =>
                      StreamChat(client: client, child: const AuthWrapper()),
            },
          );
        },
      ),
    );
  }
}
