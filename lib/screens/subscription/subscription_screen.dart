import 'package:flutter/material.dart';
import 'package:lingowise/screens/screens.dart';

class SubscriptionScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;
  
  const SubscriptionScreen({super.key, required this.onLocaleChange});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;
  String? _selectedPlan;

  Future<void> _selectPlanAndNavigate(String plan) async {
    setState(() {
      _isLoading = true;
      _selectedPlan = plan;
    });

    // Simulate subscription process
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(onLocaleChange: widget.onLocaleChange),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Subscription"),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Select your subscription plan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    title: "Free Plan",
                    price: "Free",
                    features: [
                      "Basic chat features",
                      "Limited language support",
                      "Standard support",
                    ],
                    onTap: () => _selectPlanAndNavigate("free"),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    title: "Premium Plan",
                    price: "\$9.99/month",
                    features: [
                      "All chat features",
                      "All languages supported",
                      "Priority support",
                      "Advanced features",
                    ],
                    isPremium: true,
                    onTap: () => _selectPlanAndNavigate("premium"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "RECOMMENDED",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
} 
