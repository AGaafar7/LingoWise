import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/services/settings_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lingowise/screens/subscription_screen.dart';
import 'package:lingowise/main.dart';

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

class OnboardingScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const OnboardingScreen({super.key, required this.onLocaleChange});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _isLoading = false;

  Future<void> _saveLanguageAndNavigate(String languageCode) async {
    setState(() => _isLoading = true);
    try {
      // Save the selected language
      await _settingsService.setLanguage(languageCode);
      
      // Update the app locale
      widget.onLocaleChange(Locale(languageCode));
      
      // Navigate to subscription screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving language: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Choose your preferred language",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: supportedLocales.length,
                      itemBuilder: (context, index) {
                        final locale = supportedLocales[index];
                        final languageName = _getLanguageName(locale.languageCode);
                        
                        return ListTile(
                          title: Text(languageName),
                          trailing: Text(locale.languageCode.toUpperCase()),
                          onTap: () => _saveLanguageAndNavigate(locale.languageCode),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'hi':
        return 'हिन्दी';
      case 'ms':
        return 'Bahasa Melayu';
      case 'tr':
        return 'Türkçe';
      case 'id':
        return 'Bahasa Indonesia';
      case 'bn':
        return 'বাংলা';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return languageCode.toUpperCase();
    }
  }
} 
