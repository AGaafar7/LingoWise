import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          //Implement in all the webview that will show the policies
          _buildHelpOption(
            icon: Icons.security,
            title: "Privacy Policy",
            onTap: () {
              // Handle Privacy Policy action
            },
          ),
          _buildHelpOption(
            icon: Icons.description,
            title: "Terms And Conditions",
            onTap: () {
              // Handle Terms And Conditions action
            },
          ),
          _buildHelpOption(
            icon: Icons.help_outline,
            title: "FAQ",
            onTap: () {
              // Handle FAQ action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
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
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}
