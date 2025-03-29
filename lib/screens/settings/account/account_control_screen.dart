import 'package:flutter/material.dart';
import 'package:lingowise/custom/settings_tile.dart';
import 'package:lingowise/screens/screens.dart';

class AccountControlScreen extends StatefulWidget {
  const AccountControlScreen({super.key});

  @override
  State<AccountControlScreen> createState() => _AccountControlScreenState();
}

class _AccountControlScreenState extends State<AccountControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text("Account"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final List<IconData> leadingIcons = [
                  Icons.account_circle_rounded,
                  Icons.dialpad_rounded,
                  Icons.delete_rounded,
                  Icons.sync_alt_rounded,
                  Icons.logout_rounded,
                ];
                final List<String> titles = [
                  "My Profile",
                  "My Number",
                  "Delete Account",
                  "Change Number",
                  "Logout",
                ];
                final List<String> tilesSubtitle = [
                  "My Name, status and QR code",
                  "",
                  "",
                  "",
                  "",
                ];

                return InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    } else if (index == 2) {
                      //TODO: Add Here A deletion popup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Placeholder()),
                      );
                    } else if (index == 3) {
                      //TODO: Add Here changing number popup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Placeholder()),
                      );
                    } else if (index == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                  child: SettingsTile(
                    leadingIcon: Icon(leadingIcons[index]),
                    tileTitle: titles[index],
                    tileSubtitle: tilesSubtitle[index],
                    trailingIcon: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                );
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
