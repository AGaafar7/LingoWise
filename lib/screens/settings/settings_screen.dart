import 'package:flutter/material.dart';

import 'package:lingowise/custom/customs.dart';
import 'package:lingowise/screens/screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const CustomAppBar(title: "Settings"),
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
                    Icons.help_rounded,
                  ];
                  final List<String> titles = [
                    "Account",
                    "Privacy",
                    "Chat",
                    "Help",
                  ];
                  final List<String> tilesSubtitle = [
                    "My number, delete my account, change number, change subscription",
                    "privacy settings",
                    "Language, theme, chat background",
                    "Privacy policy, terms & conditions",
                  ];
                  return InkWell(
                    onTap: () {
                      if (index == 0) {
                        //Show Account Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountControlScreen(),
                          ),
                        );
                      } else if (index == 1) {
                        //Show Privacy Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyControlScreen(),
                          ),
                        );
                      } else if (index == 2) {
                        //Show Chat Control Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatControlScreen(),
                          ),
                        );
                      } else if (index == 3) {
                        //Show Help Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      }
                    },
                    child: SettingsTile(
                      leadingIcon: Icon(leadingIcons[index]),
                      tileTitle: titles[index],
                      tileSubtitle: tilesSubtitle[index],
                      trailingIcon: const Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  );
                },
                itemCount: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF071A2C), // Dark theme color
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.qr_code), onPressed: () {}),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
