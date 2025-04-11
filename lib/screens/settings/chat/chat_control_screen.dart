import 'package:flutter/material.dart';
import 'package:lingowise/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lingowise/screens/settings/language_selection_screen.dart';

class ChatControlScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const ChatControlScreen({super.key, required this.onLocaleChange});

  @override
  State<ChatControlScreen> createState() => _ChatControlScreenState();
}

class _ChatControlScreenState extends State<ChatControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chatSettings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(AppLocalizations.of(context)!.currentLanguage),
            onTap: () async {
              final selectedLanguage = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
              if (selectedLanguage != null) {
                widget.onLocaleChange(Locale(selectedLanguage));
              }
            },
          ),
          const Divider(),
          // Add other chat settings here
        ],
      ),
    );
  }
}
