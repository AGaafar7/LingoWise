import 'package:flutter/material.dart';
import 'package:lingowise/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatControlScreen extends StatefulWidget {
  const ChatControlScreen({super.key});

  @override
  State<ChatControlScreen> createState() => _ChatControlScreenState();
}

class _ChatControlScreenState extends State<ChatControlScreen> {
  String selectedOption = "Everyone";

  void _showLanguageDialog() {
    //save the the selected theme in the app and reload with that theme
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
                    value: "English",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      Navigator.pop(context, selectedOption);
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
                    groupValue:
                        themeProvider.themeMode == ThemeMode.dark
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
                    groupValue:
                        themeProvider.themeMode == ThemeMode.light
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
              // Handle language selection
              _showLanguageDialog();
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
