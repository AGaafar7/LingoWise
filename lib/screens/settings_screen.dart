import 'package:flutter/material.dart';

import 'package:lingowise/custom/customs.dart';

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
                  //TODO: Create two lists of icons and titles and subtitle and the trailing icon
                  return SettingsTile(
                    leadingIcon: Icon(Icons.account_circle_rounded),
                    tileTitle: "Account",
                    tileSubtitle: "My Number",
                    trailingIcon: Icon(Icons.arrow_forward_ios_rounded),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
