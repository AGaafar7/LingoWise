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
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// List of supported locales
const supportedLocales = [
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
];

// Function to get the device's locale
Locale getDeviceLocale() {
  final String defaultLocale = Platform.localeName;
  final List<String> localeParts = defaultLocale.split('_');
  
  if (localeParts.length >= 2) {
    final languageCode = localeParts[0].toLowerCase();
    final countryCode = localeParts[1].toUpperCase();
    
    // First try to match both language and country
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode && locale.countryCode == countryCode) {
        return locale;
      }
    }
    
    // If no exact match, try to match just the language
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) {
        return locale;
      }
    }
  }
  
  // If no match found, return English as default
  return const Locale('en', 'US');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.init();

  // Get saved language or device language
  final savedLanguage = settingsService.getLanguage();
  final deviceLocale = getDeviceLocale();
  
  // Use saved language if available, otherwise use device language
  final initialLocale = savedLanguage.isNotEmpty 
      ? Locale(savedLanguage) 
      : deviceLocale;

  final client = StreamChatClient(
    '8w7w6b93ktuu',
    logLevel: Level.INFO,
  );

  final authService = AuthService();

  runApp(MyApp(
    client: client,
    initialLocale: initialLocale,
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
            supportedLocales: supportedLocales,
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
