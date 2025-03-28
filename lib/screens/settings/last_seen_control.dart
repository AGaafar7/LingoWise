import 'package:flutter/material.dart';

class LastSeenControl extends StatelessWidget {
  const LastSeenControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: const Text("Last Seen & Online"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Last Seen Row**
            ListTile(
              title: const Text("Last Seen"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Everyone"),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
              onTap: () {}, // Add action if needed
            ),
            const Divider(),

            /// **Online Visibility Section**
            const Text(
              "Online Visibility",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ListTile(
              title: const Text("Who can see when I'm online"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Everyone"),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
              onTap: () {}, // Add action if needed
            ),
            const SizedBox(height: 8), // Add spacing before the long text
            const Text(
              "Choosing 'Nobody' will prevent others from seeing when you were last online, as well as prevent you from seeing when others in your contacts were last available.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
