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
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final List<IconData> leadingIcons = [
                    Icons.account_circle_rounded,
                    Icons.privacy_tip_rounded,
                    Icons.chat_bubble_rounded,
                    Icons.cloud_done_rounded,
                    Icons.help_rounded,
                    Icons.notifications_active_rounded,
                    Icons.people_rounded,
                  ];
                  final List<String> titles = [
                    "Account",
                    "Privacy",
                    "Chat",
                    "Storage and Data",
                    "Help",
                    "Notification",
                    "Invite Friends",
                  ];
                  final List<String> tilesSubtitle = [
                    "My number, delete my account, change number, change subscription",
                    "Blocked contacts",
                    "app lock, hide chat",
                    "Language, theme, chat background",
                    "Media download, network usage",
                    "Privacy policy, terms & conditions",
                    "Messages, calls & group alerts",
                    "",
                  ];
                  return SettingsTile(
                    leadingIcon: Icon(leadingIcons[index]),
                    tileTitle: titles[index],
                    tileSubtitle: tilesSubtitle[index],
                    trailingIcon: Icon(Icons.arrow_forward_ios_rounded),
                  );
                },
                itemCount: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
