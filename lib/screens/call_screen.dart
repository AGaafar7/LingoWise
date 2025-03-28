import 'package:flutter/material.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calls"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "All"), Tab(text: "Missed")],
          indicatorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implement menu options
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildEmptyCallList(), _buildEmptyCallList()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement call action
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add_call),
      ),
    );
  }

  Widget _buildEmptyCallList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.call, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text(
            "You don’t have any call records to display.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            "To start calling, tap the call button below.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement invite functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Invite Your Contact"),
          ),
        ],
      ),
    );
  }
}
