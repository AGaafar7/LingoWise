import 'package:flutter/material.dart';
import 'package:lingowise/l10n/app_localizations.dart';
import 'package:lingowise/services/settings_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;
  final _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _settingsService.getLanguage();
  }

  void _changeLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
    });
    await _settingsService.setLanguage(languageCode);
    if (mounted) {
      Navigator.pop(context, languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: ListView(
        children: [
          _buildLanguageTile('English', 'en', '🇺🇸'),
          _buildLanguageTile('Arabic', 'ar', '🇸🇦'),
          _buildLanguageTile('German', 'de', '🇩🇪'),
          _buildLanguageTile('French', 'fr', '🇫🇷'),
          _buildLanguageTile('Spanish', 'es', '🇪🇸'),
          _buildLanguageTile('Portuguese', 'pt', '🇵🇹'),
          _buildLanguageTile('Russian', 'ru', '🇷🇺'),
          _buildLanguageTile('Chinese', 'zh', '🇨🇳'),
          _buildLanguageTile('Japanese', 'ja', '🇯🇵'),
          _buildLanguageTile('Korean', 'ko', '🇰🇷'),
          _buildLanguageTile('Hindi', 'hi', '🇮🇳'),
          _buildLanguageTile('Malay', 'ms', '🇲🇾'),
          _buildLanguageTile('Turkish', 'tr', '🇹🇷'),
          _buildLanguageTile('Indonesian', 'id', '🇮🇩'),
          _buildLanguageTile('Bengali', 'bn', '🇧🇩'),
          _buildLanguageTile('Vietnamese', 'vi', '🇻🇳'),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(String languageName, String languageCode, String flag) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(languageName),
      trailing: _selectedLanguage == languageCode
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () => _changeLanguage(languageCode),
    );
  }
} 
