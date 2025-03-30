import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class Language {
  final String code;
  final String name;
  final String flag;

  Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  final bool isSourceLanguage;

  const LanguageSelectionScreen({
    Key? key,
    required this.isSourceLanguage,
  }) : super(key: key);

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Language> _languages = [
    Language(code: 'en', name: 'English', flag: '🇺🇸'),
    Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    Language(code: 'de', name: 'German', flag: '🇩🇪'),
    Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    Language(code: 'ru', name: 'Russian', flag: '🇷🇺'),
    Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
    Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    Language(code: 'ar', name: 'Arabic', flag: '🇸🇦'),
    Language(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
  ];

  String _searchQuery = '';
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Language> get _filteredLanguages {
    return _languages.where((language) {
      return language.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          language.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _selectLanguage(Language language) async {
    if (widget.isSourceLanguage) {
      await _prefs.setString('source_language_code', language.code);
      await _prefs.setString('source_language_name', language.name);
      print('Selected source language: ${language.code}'); // Debug print
    } else {
      await _prefs.setString('target_language_code', language.code);
      await _prefs.setString('target_language_name', language.name);
      print('Selected target language: ${language.code}'); // Debug print
    }
    if (mounted) {
      Navigator.pop(context, language);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSourceLanguage ? 'Select Source Language' : 'Select Target Language',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search language...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                return ListTile(
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(language.name),
                  subtitle: Text(language.code.toUpperCase()),
                  onTap: () => _selectLanguage(language),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 