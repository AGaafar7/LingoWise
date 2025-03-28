import 'package:flutter/material.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool isPinLockEnabled = false;
  bool isFingerprintEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text("App Lock"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggleOption(
              title: "PIN Lock",
              subtitle: "Add more security with a 6-digit secret PIN",
              value: isPinLockEnabled,
              onChanged: (value) {
                setState(() {
                  isPinLockEnabled = value;
                });
              },
            ),
            _buildToggleOption(
              title: "Fingerprint ID",
              subtitle: "Enable Fingerprint ID to unlock the app",
              value: isFingerprintEnabled,
              onChanged: (value) {
                setState(() {
                  isFingerprintEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: Switch(value: value, onChanged: onChanged),
        ),
        const Divider(),
      ],
    );
  }
}
