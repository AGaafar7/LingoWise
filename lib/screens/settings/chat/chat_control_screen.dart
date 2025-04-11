import 'package:flutter/material.dart';
import 'package:lingowise/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatControlScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const ChatControlScreen({super.key, required this.onLocaleChange});

  @override
  State<ChatControlScreen> createState() => _ChatControlScreenState();
}

class _ChatControlScreenState extends State<ChatControlScreen> {
  String selectedOption = "en";

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Dark theme compatible
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text("English"),
                    value: "en",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('en'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Spanish"),
                    value: "es",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('es'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("French"),
                    value: "fr",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('fr'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("German"),
                    value: "de",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('de'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Arabic"),
                    value: "ar",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      Navigator.pop(context, selectedOption);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Portuguese"),
                    value: "pt",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('pt'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Russian"),
                    value: "ru",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('ru'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Chinese"),
                    value: "zh",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('zh'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Japanese"),
                    value: "ja",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('ja'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Korean"),
                    value: "ko",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('ko'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Hindi"),
                    value: "hi",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('hi'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Malay"),
                    value: "ms",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('ms'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Turkish"),
                    value: "tr",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('tr'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Indonesian"),
                    value: "id",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('id'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Bengali"),
                    value: "bn",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('bn'));
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Vietnamese"),
                    value: "vi",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      widget.onLocaleChange(const Locale('vi'));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedOption = value;
        });
      }
    });
  }

  void _showThemeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Theme",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text("Dark"),
                    value: "Dark",
                    groupValue: themeProvider.themeMode == ThemeMode.dark
                        ? "Dark"
                        : "Light",
                    onChanged: (value) {
                      themeProvider.toggleTheme(value!);
                      Navigator.pop(context);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Light"),
                    value: "Light",
                    groupValue: themeProvider.themeMode == ThemeMode.light
                        ? "Light"
                        : "Dark",
                    onChanged: (value) {
                      themeProvider.toggleTheme(value!);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text("Chat"),
      ),
      body: ListView(
        children: [
          _buildSettingOption(
            icon: Icons.language,
            title: "Language",
            subtitle: "English",
            onTap: () {
              // Handle "English"wLanguageDialog();
            },
          ),
          _buildSettingOption(
            icon: Icons.color_lens,
            title: "Theme",
            subtitle: "System Default",
            onTap: () {
              // Handle theme selection
              _showThemeDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.tealAccent),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
