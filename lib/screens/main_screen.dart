import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';
import 'package:lingowise/services/auth_service.dart' show AuthService;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currIndex = 0;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        print("✅ Firebase User Found: ${user.uid}");

        // 🔹 Manually Initialize Stream Chat
        await authService.initializeStreamClient(user.uid);

        print("🔍 Checking Stream Chat user after initialization...");
        if (authService.streamClient == null ||
            authService.streamClient!.state.currentUser == null) {
          print(
              "❌ Stream Client still not initialized or user not authenticated in Stream!");
        } else {
          print(
              "✅ Stream Chat authenticated as: ${authService.streamClient!.state.currentUser!.id}");
        }
      } else {
        print("❌ No Firebase user found!");
      }
    });
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      currIndex = index;
    });
  }

  final List<Widget> screens = [
    const ChatMainScreen(),
    const CallsScreen(),
    const ContactScreen(),
    const SettingsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(index: currIndex, children: screens),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF071A2C), // Dark background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.chat, "Chats", 0),
          _buildBottomNavItem(Icons.phone, "Calls", 1),
          _buildBottomNavItem(Icons.contacts, "Contacts", 2),
          _buildBottomNavItem(Icons.settings, "Settings", 3),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    bool isSelected = currIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
