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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.init();

  // Get saved language
  final savedLanguage = settingsService.getLanguage();

  final client = StreamChatClient(
    '8w7w6b93ktuu',
    logLevel: Level.INFO,
  );

  final authService = AuthService();

  runApp(MyApp(
    client: client,
    initialLocale: Locale(savedLanguage),
  ));
}

class MyApp extends StatefulWidget {
  final StreamChatClient client;
  final Locale initialLocale;

  const MyApp({
    super.key,
    required this.client,
    required this.initialLocale,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('ar', 'SA'), // Arabic
              Locale('de', 'DE'), // German
              Locale('fr', 'FR'), // French
              Locale('es', 'ES'), // Spanish
              Locale('pt', 'PT'), // Portuguese
              Locale('ru', 'RU'), // Russian
              Locale('zh', 'CN'), // Chinese
              Locale('ja', 'JP'), // Japanese
              Locale('ko', 'KR'), // Korean
              Locale('hi', 'IN'), // Hindi
              Locale('ms', 'MY'), // Malay
              Locale('tr', 'TR'), // Turkish
              Locale('id', 'ID'), // Indonesian
              Locale('bn', 'BD'), // Bengali
              Locale('vi', 'VN'), // Vietnamese
            ],
            navigatorKey: navigatorKey,
            home: StreamChat(
              client: widget.client,
              child: AuthWrapper(onLocaleChange: _setLocale),
            ),
          );
        },
      ),
    );
  }
}
