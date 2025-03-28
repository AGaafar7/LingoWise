import 'package:flutter/material.dart';
import 'package:lingowise/custom/customs.dart';
import 'package:lingowise/screens/screens.dart';

class PrivacyControlScreen extends StatefulWidget {
  const PrivacyControlScreen({super.key});

  @override
  State<PrivacyControlScreen> createState() => _PrivacyControlScreenState();
}

class _PrivacyControlScreenState extends State<PrivacyControlScreen> {
  String selectedOption = "Everyone"; // Default selected option

  void _showProfilePhotoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Dark theme compatible
      shape: RoundedRectangleBorder(
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
                    "Profile photo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text("Everyone"),
                    value: "Everyone",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      Navigator.pop(context, selectedOption);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Nobody"),
                    value: "Nobody",
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

  void _showGroupDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Dark theme compatible
      shape: RoundedRectangleBorder(
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
                    "Who can add me in the group",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text("Everyone"),
                    value: "Everyone",
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                      Navigator.pop(context, selectedOption);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Nobody"),
                    value: "Nobody",
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
        title: Text("Privacy"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final List<IconData> leadingIcons = [
                  Icons.remove_red_eye_outlined,
                  Icons.account_circle_outlined,
                  Icons.lock,
                  Icons.group_add_rounded,
                  Icons.chat_bubble_outline_rounded,
                ];
                final List<String> titles = [
                  "Last Seen & Online",
                  "Profile Photo",
                  "App Lock",
                  "Groups",
                  "Read Receipt",
                ];
                final List<String> tilesSubtitle = [
                  "",
                  "",
                  "",
                  "",
                  "By turning this option off, you will neither receive other poeple's read receipts, nor will they receive yours. However, in group chats, read receipts are always sent.",
                ];
                return InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LastSeenControl(),
                        ),
                      );
                    } else if (index == 1) {
                      _showProfilePhotoDialog();
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppLockScreen(),
                        ),
                      );
                    } else if (index == 3) {
                      _showGroupDialog();
                    }
                    //index 4 is the read reciept it will have a toggle to turn on and off
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
