import 'package:flutter/material.dart';
import 'package:lingowise/screens/language_selection_screen.dart';
import 'package:lingowise/services/translation_service.dart';
import 'package:lingowise/services/subscription_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TranslationService _translationService = TranslationService();
  final TextEditingController _sourceTextController = TextEditingController();
  final TextEditingController _targetTextController = TextEditingController();
  bool _isLoading = false;
  String _sourceLanguage = 'English';
  String _targetLanguage = 'Spanish';

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final sourceLang = await _translationService.getSourceLanguage();
    final targetLang = await _translationService.getTargetLanguage();
    setState(() {
      _sourceLanguage = sourceLang;
      _targetLanguage = targetLang;
    });
  }

  Future<void> _selectLanguage(bool isSource) async {
    final selectedLanguage = await Navigator.push<Language>(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageSelectionScreen(
          isSourceLanguage: isSource,
        ),
      ),
    );

    if (selectedLanguage != null) {
      setState(() {
        if (isSource) {
          _sourceLanguage = selectedLanguage.name;
        } else {
          _targetLanguage = selectedLanguage.name;
        }
      });
    }
  }

  Future<void> _translate() async {
    if (_sourceTextController.text.isEmpty) return;

    final hasEnoughUnits = await _translationService.hasEnoughUnits(
      _sourceTextController.text.length,
    );

    if (!hasEnoughUnits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough units. Please purchase more units.'),
          action: SnackBarAction(
            label: 'Purchase',
            onPressed: null, // Navigate to subscription screen
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final translatedText = await _translationService.translate(
        _sourceTextController.text,
      );
      await _translationService.useUnits(_sourceTextController.text.length);
      setState(() {
        _targetTextController.text = translatedText;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Translation error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Source Language Selection
            ListTile(
              title: const Text('From'),
              subtitle: Text(_sourceLanguage),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _selectLanguage(true),
            ),
            // Source Text Input
            TextField(
              controller: _sourceTextController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter text to translate',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Translate Button
            ElevatedButton(
              onPressed: _isLoading ? null : _translate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Translate'),
            ),
            const SizedBox(height: 16),
            // Target Language Selection
            ListTile(
              title: const Text('To'),
              subtitle: Text(_targetLanguage),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _selectLanguage(false),
            ),
            // Target Text Output
            TextField(
              controller: _targetTextController,
              maxLines: 5,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Translation will appear here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sourceTextController.dispose();
    _targetTextController.dispose();
    super.dispose();
  }
} 