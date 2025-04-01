import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lingowise/screens/auth_failed_screen.dart'
    show AuthenticationFailedScreen;
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:lingowise/theme/theme_provider.dart';
import 'package:lingowise/services/settings_service.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:lingowise/services/auth_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize settings service
  await SettingsService().init();

  final client = StreamChatClient(
    '8w7w6b93ktuu',
    logLevel: Level.INFO,
  );

  final authService = AuthService();

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final StreamChatClient client;

  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LingoWise',
            theme: appThemeLight,
            darkTheme: appThemeDark,
            themeMode: themeProvider.themeMode,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            navigatorKey: navigatorKey,
            supportedLocales: const [Locale('en', 'US')],
            home: StreamChat(
              client: client,
              child: AuthWrapper(),
            ),
          );
        },
      ),
    );
  }
}
