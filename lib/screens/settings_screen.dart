import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Text("Settings"),
          actions: [
            IconButton(
              onPressed: () => debugPrint("QR Code"),
              icon: Icon(Icons.qr_code_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return const SizedBox();
                },
              ),
            ),
            Placeholder(color: Colors.red),
          ],
        ),
      ),
    );
  }
}
