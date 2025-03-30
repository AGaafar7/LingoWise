import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //TODO: Edit Functionality and popup
  //TODO: Add the change and upload image icon
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.amber),
          Row(
            children: [
              const CircleAvatar(radius: 10),
              const Column(children: [Text("Name"), Text("Ahmed Gaafar")]),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const CircleAvatar(radius: 10),
              const Column(
                children: [Text("Status"), Text("Hello! I'm on LingoWise")],
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              CircleAvatar(radius: 10),
              Column(children: [Text("QR Code")]),
            ],
          ),
        ],
      ),
    );
  }
}
