import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: CircleAvatar(radius: 25),
          title: const Text("Nour Amira"),
          actions: [
            IconButton(
              onPressed: () => debugPrint("Calls"),
              icon: Icon(Icons.call_rounded),
            ),
            IconButton(
              onPressed: () => debugPrint("Search"),
              icon: Icon(Icons.search_rounded),
            ),
            IconButton(
              onPressed: () => debugPrint("Menu"),
              icon: Icon(Icons.menu_rounded),
            ),
          ],
        ),
        body: Column(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_forwarded_rounded),
              label: "Calls",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_page_rounded),
              label: "Contacts",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
