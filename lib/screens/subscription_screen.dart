import 'package:flutter/material.dart';
import 'package:lingowise/services/subscription_service.dart';
import 'package:pay/pay.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  SubscriptionPackage? _selectedPackage;
  bool _isLoading = false;
  final _paymentItems = <PaymentItem>[];
  final _googlePayButton = GooglePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(
      '''{
        "provider": "google_pay",
        "data": {
          "environment": "TEST",
          "apiVersion": 2,
          "apiVersionMinor": 0,
           "merchantInfo": {
          "merchantId": "BCR2DN4T27NY7HB4",
          "merchantName": "lingowise"
        },
          "allowedPaymentMethods": [
            {
              "type": "CARD",
              "data": {
                "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                "allowedCardNetworks": ["VISA", "MASTERCARD"]
              }
            }
          ]
        }
      }''',
    ),
  );

  final _applePayButton = ApplePayButton(
    paymentConfiguration: PaymentConfiguration.fromJsonString(
      '''{
        "provider": "apple_pay",
        "data": {
          "merchantIdentifier": "merchant.com.lingowise.app",
          "displayName": "LingoWise",
          "merchantCapabilities": ["3DS", "debit", "credit"],
          "merchantCapabilities": ["3DS", "debit", "credit"],
          "allowedPaymentNetworks": ["visa", "masterCard", "amex"]
        }
      }''',
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionService();
  }

  Future<void> _initializeSubscriptionService() async {
    await _subscriptionService.init();
    setState(() {});
  }

  void _selectPackage(SubscriptionPackage package) {
    setState(() {
      _selectedPackage = package;
      _updatePaymentItems();
    });
  }

  void _updatePaymentItems() {
    if (_selectedPackage == null) return;

    _paymentItems.clear();
    _paymentItems.add(
      PaymentItem(
        label: _selectedPackage!.name,
        amount: _selectedPackage!.price.toString(),
      ),
    );
  }

  Future<void> _handlePayment(PaymentResult result) async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedPackage!.isFree) {
        await _subscriptionService.addUnits(_selectedPackage!.units);
      } else {
        // Handle payment result and add units
        await _subscriptionService.addUnits(_selectedPackage!.units);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPackageCard(SubscriptionPackage package) {
    final isSelected = _selectedPackage?.id == package.id;
    final isFree = package.isFree;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _selectPackage(package),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!isFree)
                    Text(
                      '\$${package.price}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(package.description),
              if (isSelected) ...[
                const SizedBox(height: 16),
                if (!isFree) ...[
                  _googlePayButton,
                  const SizedBox(height: 8),
                  _applePayButton,
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Handle PayPal payment
                    },
                    child: const Text('Pay with PayPal'),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () => _handlePayment(PaymentResult()),
                    child: const Text('Get Free Plan'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_subscriptionService.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a plan to get started',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ..._subscriptionService.packages.map(_buildPackageCard),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
} 