import 'package:flutter/material.dart';
import 'package:lingowise/screens/language_selection_screen.dart';
import 'package:lingowise/services/translation_service.dart' as translation;
import 'package:lingowise/services/usage_tracking_service.dart' as usage;
import 'package:lingowise/services/subscription_service.dart' as subscription;

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({Key? key}) : super(key: key);

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _sourceController = TextEditingController();
  final _targetController = TextEditingController();
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';
  bool _isLoading = false;
  String? _error;

  final translation.TranslationService _translationService = translation.TranslationService();
  final usage.UsageTrackingService _usageTracking = usage.UsageTrackingService();
  final subscription.SubscriptionService _subscriptionService = subscription.SubscriptionService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _translationService.initialize();
    await _subscriptionService.initialize();
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) {
      setState(() => _error = 'Please enter text to translate');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hasUnits = await _subscriptionService.hasActiveSubscription();
      if (!hasUnits) {
        setState(() => _error = 'No subscription units available. Please upgrade your plan.');
        return;
      }

      final result = await _translationService.translate(
        text: _sourceController.text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      setState(() {
        _targetController.text = result;
        _isLoading = false;
      });

      // Track usage
      await _usageTracking.trackTranslationUsage(
        textLength: _sourceController.text.length,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );
    } catch (e) {
      setState(() {
        _error = 'Translation failed: ${e.toString()}';
        _isLoading = false;
      });
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    decoration: const InputDecoration(
                      labelText: 'From',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      DropdownMenuItem(value: 'de', child: Text('German')),
                      DropdownMenuItem(value: 'it', child: Text('Italian')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sourceLanguage = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'es', child: Text('Spanish')),
                      DropdownMenuItem(value: 'fr', child: Text('French')),
                      DropdownMenuItem(value: 'de', child: Text('German')),
                      DropdownMenuItem(value: 'it', child: Text('Italian')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _targetLanguage = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Enter text to translate',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _translate,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Translate'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }
} 